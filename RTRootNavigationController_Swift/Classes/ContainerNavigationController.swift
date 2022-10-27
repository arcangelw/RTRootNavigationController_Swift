// Copyright (c) 2022 wuzhe <wuzhezmc@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

// swiftlint:disable line_length

/// 独立导航控制器容器
@objc(RTContainerNavigationController)
public final class ContainerNavigationController: UINavigationController {
    /// init
    override public init(rootViewController: UIViewController) {
        super.init(navigationBarClass: rootViewController.rt_navigationBarClass(), toolbarClass: nil)
        pushViewController(rootViewController, animated: false)
        // use following way will cause bug
        // viewControllers = [rootViewController]
    }

    /// init
    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
    }

    /// init
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.isEnabled = false
        super.delegate = self
        guard rt_navigationController?.transferNavigationBarAttributes ?? false else { return }
        guard let rtNavigationBar = navigationController?.navigationBar else { return }
        navigationBar.isTranslucent = rtNavigationBar.isTranslucent
        navigationBar.tintColor = rtNavigationBar.tintColor
        navigationBar.barTintColor = rtNavigationBar.barTintColor
        navigationBar.barStyle = rtNavigationBar.barStyle
        navigationBar.backgroundColor = rtNavigationBar.backgroundColor
        navigationBar.setBackgroundImage(rtNavigationBar.backgroundImage(for: .default), for: .default)
        navigationBar.setTitleVerticalPositionAdjustment(rtNavigationBar.titleVerticalPositionAdjustment(for: .default), for: .default)
        navigationBar.titleTextAttributes = rtNavigationBar.titleTextAttributes
        navigationBar.shadowImage = rtNavigationBar.shadowImage
        navigationBar.backIndicatorImage = rtNavigationBar.backIndicatorImage
        navigationBar.backIndicatorTransitionMaskImage = rtNavigationBar.backIndicatorTransitionMaskImage
        if #available(iOS 13.0, *) {
            navigationBar.standardAppearance = rtNavigationBar.standardAppearance
            navigationBar.compactAppearance = rtNavigationBar.compactAppearance
            navigationBar.scrollEdgeAppearance = rtNavigationBar.scrollEdgeAppearance
        }
        if #available(iOS 15.0, *) {
            navigationBar.compactScrollEdgeAppearance = rtNavigationBar.compactScrollEdgeAppearance
        }
    }

    /// viewDidLayoutSubviews
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let viewController = topViewController else { return }
        if !viewController.rt_hasSetInteractivePop {
            let hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil
            if isNavigationBarHidden {
                viewController.rt_disableInteractivePop = true
                // viewController.rt_disableEdgeInteractivePop = true
            } else if hasSetLeftItem {
                viewController.rt_disableInteractivePop = true
                // viewController.rt_disableEdgeInteractivePop = true
            } else {
                viewController.rt_disableInteractivePop = false
                // viewController.rt_disableEdgeInteractivePop = false
            }
        }
        if parent is ContainerController, parent?.parent is RootNavigationController {
            rt_navigationController?.installsLeftBarButtonItemIfNeeded(for: viewController)
        }
    }

    /// tabBarController
    override public var tabBarController: UITabBarController? {
        guard let tabBarController = super.tabBarController else { return nil }
        guard let navigationController = rt_navigationController else { return tabBarController }
        if tabBarController != navigationController.tabBarController {
            // Tab is child of Root VC
            return tabBarController
        } else {
            return !tabBarController.tabBar.isTranslucent || navigationController.rt_viewControllers.contains(where: { $0.hidesBottomBarWhenPushed }) ? nil : tabBarController
        }
    }

    /// viewControllers
    override public var viewControllers: [UIViewController] {
        get {
            if navigationController is RootNavigationController {
                return rt_navigationController?.rt_viewControllers ?? []
            }
            return super.viewControllers
        }
        set {
            super.viewControllers = newValue
        }
    }

    /// allowedChildrenForUnwinding
    override public func allowedChildrenForUnwinding(from source: UIStoryboardUnwindSegueSource) -> [UIViewController] {
        if let navigationController = navigationController {
            return navigationController.allowedChildrenForUnwinding(from: source)
        }
        return super.allowedChildrenForUnwinding(from: source)
    }

    /// pushViewController
    override public func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }

    /// forwardingTarget
    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        guard navigationController?.responds(to: aSelector) ?? false else { return nil }
        return navigationController
    }

    /// popViewController
    override public func popViewController(animated: Bool) -> UIViewController? {
        if let navigationController = navigationController {
            return navigationController.popViewController(animated: animated)
        }
        return super.popViewController(animated: animated)
    }

    /// popToRootViewController
    override public func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if let navigationController = navigationController {
            return navigationController.popToRootViewController(animated: animated)
        }
        return super.popToRootViewController(animated: animated)
    }

    /// popToViewController
    override public func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if let navigationController = navigationController {
            return navigationController.popToViewController(viewController, animated: animated)
        }
        return super.popToViewController(viewController, animated: animated)
    }

    /// setViewControllers
    override public func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        if let navigationController = navigationController {
            navigationController.setViewControllers(viewControllers, animated: animated)
        } else {
            super.setViewControllers(viewControllers, animated: animated)
        }
    }

    /// delegate
    override public var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            if let navigationController = navigationController {
                navigationController.delegate = newValue
            } else {
                super.delegate = newValue
            }
        }
    }

    /// setNavigationBarHidden
    override public func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        super.setNavigationBarHidden(hidden, animated: animated)
        if visibleViewController?.rt_hasSetInteractivePop == false {
            visibleViewController?.rt_disableInteractivePop = hidden
            visibleViewController?.rt_disableEdgeInteractivePop = hidden
        }
    }

    /// preferredStatusBarStyle
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? super.preferredStatusBarStyle
    }

    /// prefersStatusBarHidden
    override public var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? super.prefersStatusBarHidden
    }

    /// preferredStatusBarUpdateAnimation
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return topViewController?.preferredStatusBarUpdateAnimation ?? super.preferredStatusBarUpdateAnimation
    }

    /// childForScreenEdgesDeferringSystemGestures
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return topViewController
    }

    /// preferredScreenEdgesDeferringSystemGestures
    override public var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return topViewController?.preferredScreenEdgesDeferringSystemGestures ?? super.preferredScreenEdgesDeferringSystemGestures
    }

    /// prefersHomeIndicatorAutoHidden
    override public var prefersHomeIndicatorAutoHidden: Bool {
        return topViewController?.prefersHomeIndicatorAutoHidden ?? super.prefersHomeIndicatorAutoHidden
    }

    /// childForHomeIndicatorAutoHidden
    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        return topViewController
    }
}

// MARK: - UINavigationControllerDelegate

extension ContainerNavigationController: UINavigationControllerDelegate {
    /// UINavigationControllerDelegate
    public func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        if viewController.rt_prefersNavigationBarHidden {
            setNavigationBarHidden(true, animated: false)
        }
    }
}

// swiftlint:enable line_length
