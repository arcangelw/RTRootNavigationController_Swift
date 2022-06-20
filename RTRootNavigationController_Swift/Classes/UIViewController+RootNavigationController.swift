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

// swiftlint:disable line_length identifier_name

/// 自定义返回按钮
@objc(RTNavigationItemCustomizable)
public protocol NavigationItemCustomizable: AnyObject {
    /// 自定义返回按钮
    @objc
    optional func rt_customBackItem(_ target: Any, action: Selector) -> UIBarButtonItem
}

extension UIViewController: NavigationItemCustomizable {
    /// 禁止交互
    @IBInspectable
    public var rt_disableInteractivePop: Bool {
        get {
            associatedValue(key: "rt_disableInteractivePop", object: self, initialValue: false)
        }
        set {
            set(associatedValue: newValue, key: "rt_disableInteractivePop", object: self)
        }
    }

    /// 隐藏导航栏
    @IBInspectable
    public var rt_prefersNavigationBarHidden: Bool {
        get {
            associatedValue(key: "rt_prefersNavigationBarHidden", object: self, initialValue: false)
        }
        set {
            set(associatedValue: newValue, key: "rt_prefersNavigationBarHidden", object: self)
        }
    }

    /// 实际主控制器
    @objc
    public var rt_navigationController: RootNavigationController? {
        var vc: UIViewController? = self
        while vc != nil, !(vc is RootNavigationController) {
            vc = vc?.navigationController
        }
        return vc as? RootNavigationController
    }

    /// 自定义导航栏
    @objc
    open func rt_navigationBarClass() -> UINavigationBar.Type? {
        return nil
    }

    /// 自定义转场动画
    @objc
    public var rt_animatedTransitioning: UIViewControllerAnimatedTransitioning? {
        return nil
    }
}

extension UIViewController {
    /// 是否已经设置disableInteractivePop
    var rt_hasSetInteractivePop: Bool {
        return true // 默认rt_disableInteractivePop有默认值 false
        /// return hasAssociatedValue(key: "rt_disableInteractivePop", object: self)
    }

    /// hook
    @objc
    func rt_setNeedsStatusBarAppearanceUpdate() {
        rt_setNeedsStatusBarAppearanceUpdate()
        if !(self is RootNavigationController), !(self is ContainerController), !(self is ContainerNavigationController) {
            if parent is ContainerController || parent is ContainerNavigationController {
                rt_updateStatusBarAppearance(self)
            }
        }
    }
}

// swiftlint:enable line_length identifier_name
