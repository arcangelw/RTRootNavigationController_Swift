//
//  FullscreenPopGestureRecognizerDelegate.swift
//  RTRootNavigationController_Swift
//
//  Created by 吴哲 on 2022/6/22.
//

import UIKit
// swiftlint:disable line_length identifier_name

/// Page页面手势交互辅助
@objc(RTPageViewControllerHelper)
public protocol PageViewControllerHelper: AnyObject {
    @objc
    func onHomePage() -> Bool
}

/// 全屏手势处理
@objc(RTFullscreenPopGestureRecognizerDelegateCustomizable)
public protocol FullscreenPopGestureRecognizerDelegateCustomizable: UIGestureRecognizerDelegate {
    /// navigationController
    @objc
    weak var navigationController: RootNavigationController? { get set }
}

/// 全屏手势处理
final class FullscreenPopGestureRecognizerDelegate: NSObject, FullscreenPopGestureRecognizerDelegateCustomizable {
    /// navigationController
    weak var navigationController: RootNavigationController?

    /// fullscreenPopGestureRecognizer
    private var fullscreenPopGestureRecognizer: UIPanGestureRecognizer? {
        return navigationController?.fullscreenPopGestureRecognizer
    }

    /// 判断手势是否可以触发
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard
            let pan = gestureRecognizer as? UIPanGestureRecognizer,
            let nav = navigationController,
            nav.viewControllers.count > 1,
            let top = nav.rt_topViewController,
            !top.rt_disableInteractivePop
        else { return false }

        if let isTransitioning = rt_ivarValue(of: nav, forKey: "_isTransitioning") as? Bool, isTransitioning {
            return false
        }

        let translation = pan.translation(in: pan.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if translation.x * multiplier <= 0 {
            return false
        }
        // 滑动返回速度容错
        let velocity = pan.velocity(in: pan.view)
        if abs(velocity.x) < abs(velocity.y) {
            return false
        }
        return true
    }

    /// 按钮交互处理
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let view = gestureRecognizer.view else { return false }

        let location = touch.location(in: view)
        var hitView = view.hitTest(location, with: nil)

        // Traverse the chain of superviews looking for any UIControls.
        while hitView != view, hitView != nil {
            if hitView is UIControl {
                // Ensure UIControls get the touches instead of the tap gesture.
                return !(hitView as! UIControl).isEnabled // swiftlint:disable:this force_cast
            }
            hitView = hitView?.superview
        }

        return true
    }

    /// scrollView Page 手势冲突处理
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer === fullscreenPopGestureRecognizer else { return false }
        guard
            let top = navigationController?.rt_topViewController,
            case .began = gestureRecognizer.state,
            gestureRecognizer.view !== otherGestureRecognizer.view,
            let otherView = otherGestureRecognizer.view,
            type(of: otherView).isSubclass(of: UIScrollView.self)
        else { return true }
        let scrollView = otherView as! UIScrollView // swiftlint:disable:this force_cast
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.panGestureRecognizer.view)
        let isLeftToRight = UIApplication.shared.userInterfaceLayoutDirection == .leftToRight
        let multiplier: CGFloat = isLeftToRight ? 1 : -1
        if translation.x * multiplier <= 0 {
            return false
        }
        if let helper = top as? PageViewControllerHelper {
            let ishome = helper.onHomePage()
            if ishome {
                let oriScrollEnabled = scrollView.isScrollEnabled
                defer {
                    scrollView.isScrollEnabled = oriScrollEnabled
                }
                scrollView.isScrollEnabled = false
            }
            return ishome
        } else if scrollView.rt_isScrollToLeft {
            let oriScrollEnabled = scrollView.isScrollEnabled
            defer {
                scrollView.isScrollEnabled = oriScrollEnabled
            }
            scrollView.isScrollEnabled = false
            return true
        } else {
            return false
        }
    }
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy _: UIGestureRecognizer) -> Bool {
//        return gestureRecognizer === fullscreenPopGestureRecognizer
//    }
}

extension UIScrollView {
    /// Initial position
    var rt_isScrollToLeft: Bool {
        if contentOffset.x <= 0 {
            return superview?.rt_scrollView?.rt_isScrollToLeft ?? true
        }
        return false
    }
}

extension UIView {
    /// scrollView
    var rt_scrollView: UIScrollView? {
        var sub: UIView? = self
        while let view = sub, !type(of: view).isSubclass(of: UIScrollView.self) {
            sub = view.superview
        }
        return sub as? UIScrollView
    }
}

// swiftlint:enable line_length identifier_name
