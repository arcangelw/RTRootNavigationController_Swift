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
import ObjectiveC.runtime
import UIKit

// swiftlint:disable line_length identifier_name

/// 容器解包
@inline(__always)
public func rt_safeUnwrap(_ controller: UIViewController) -> UIViewController {
    if let container = controller as? ContainerController {
        return container.contentViewController
    }
    return controller
}

/// 容器包装
@inline(__always)
public func rt_safeWrap(
    _ controller: UIViewController,
    _ navigationBarClass: UINavigationBar.Type? = nil,
    _ yesOrNo: Bool = false,
    _ backItem: UIBarButtonItem? = nil,
    _ backTitle: String? = nil
) -> UIViewController {
    if !(controller is ContainerController), !(controller.parent is ContainerController) {
        return ContainerController(controller: controller, navigationBarClass: navigationBarClass, placeholderController: yesOrNo, backBarButtonItem: backItem, backTitle: backTitle)
    }
    return controller
}

/// 已经设置了状态栏
private var rt_hasSetCustomizableStatusBarAppearance = false
/// 是否可以设置状态栏
private var rt_canSetCustomizableStatusBarAppearance = false

/// 设置自定义控制状态栏
@inline(__always)
public func rt_setCustomizableStatusBarAppearance() {
    if !rt_hasSetCustomizableStatusBarAppearance, rt_isSetVCBasedStatusBarAppearance() {
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.setNeedsStatusBarAppearanceUpdate)),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.rt_setNeedsStatusBarAppearanceUpdate))
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
        rt_hasSetCustomizableStatusBarAppearance = true
        rt_canSetCustomizableStatusBarAppearance = true
    }
}

/// 是否配置自定义控制状态栏
@inline(__always)
func rt_isSetVCBasedStatusBarAppearance() -> Bool {
    /// UIViewControllerBasedStatusBarAppearance 不设置 默认是true
    return !(Bundle.main.object(forInfoDictionaryKey: "UIViewControllerBasedStatusBarAppearance") as? Bool ?? true)
}

/// 更新状态栏
@inline(__always)
public func rt_updateStatusBarAppearance(_ controller: UIViewController, animated: Bool = true) {
    guard rt_canSetCustomizableStatusBarAppearance else { return }
    let isHidden = controller.prefersStatusBarHidden
    let animation = animated ? controller.preferredStatusBarUpdateAnimation : .none
    if isHidden {
        UIApplication.shared.setStatusBarHidden(true, with: animation)
    } else {
        let style = controller.preferredStatusBarStyle
        UIApplication.shared.setStatusBarHidden(false, with: animation)
        UIApplication.shared.setStatusBarStyle(style, animated: animation != .none)
    }
}

/*
 Ivar targetsIvar = class_getInstanceVariable([pan class], "_targets");
 if (targetsIvar) {
     id result = object_getIvar(pan, targetsIvar);
     if ([result isKindOfClass:NSArray.class]) {
         id first = [result firstObject];
         Ivar targetIvar = class_getInstanceVariable([first class], "_target");
         if (targetIvar) {
             return object_getIvar(first, targetIvar);
         }
     }
 }
 return nil;
 */
// 手势
@inline(__always)
func rt_gestureTarget(_ gesture: UIGestureRecognizer) -> Any? {
    guard let targetObject = (rt_ivarValue(of: gesture, forKey: "_targets") as? [AnyObject])?.first else {
        return nil
    }
    let target = rt_ivarValue(of: targetObject, forKey: "_target")
    return target
}

/// 获取成员变量
@inline(__always)
func rt_ivarValue(of object: AnyObject, forKey key: String) -> Any? {
    let obj = type(of: object)
    if let ivar = class_getInstanceVariable(obj, key) {
        let value = object_getIvar(object, ivar)
        return value
    }
    if class_respondsToSelector(obj, NSSelectorFromString(key)) {
        let value = object.value(forKey: key)
        return value
    }
    return nil
}

// swiftlint:enable line_length identifier_name
