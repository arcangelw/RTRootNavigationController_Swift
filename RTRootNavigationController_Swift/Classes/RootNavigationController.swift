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

/// 根控制器 RTRootNavigationController
@objc(RTRootNavigationController)
open class RootNavigationController: UINavigationController {
    /// 使用系统返回按钮
    @IBInspectable
    public var useSystemBackBarButtonItem: Bool = false

    /// 是否转移导航栏属性
    @IBInspectable
    public var transferNavigationBarAttributes: Bool = false

    /// 实际可见视图控制器
    @objc
    public var rt_visibleViewController: UIViewController? {
        return super.visibleViewController.map(rt_safeUnwrap(_:))
    }

    /// 实际顶部视图控制器
    @objc
    public var rt_topViewController: UIViewController? {
        return super.topViewController.map(rt_safeUnwrap(_:))
    }

    /// 实际控制器列表
    @objc
    public var rt_viewControllers: [UIViewController] {
        return super.viewControllers.map(rt_safeUnwrap(_:))
    }

    // MARK: - private

    /// 转场动画结束
    private var completion: ((Bool) -> Void)?

    /// 外部delegate
    private weak var rt_delegate: UINavigationControllerDelegate?

    /// 全屏返回手势
    @objc
    public private(set) lazy var fullscreenPopGestureRecognizer = UIPanGestureRecognizer()

    /// 全屏手势代理
    private lazy var fullscreenPopGestureRecognizerDelegate: FullscreenPopGestureRecognizerDelegateCustomizable = FullscreenPopGestureRecognizerDelegate()

    // MARK: - Overrides

    /// awakeFromNib
    override open func awakeFromNib() {
        super.awakeFromNib()
        viewControllers = super.viewControllers
    }

    /// init
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// init
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rt_safeWrap(rootViewController, rootViewController.rt_navigationBarClass()))
        commonInit()
    }

    /// init
    @objc
    public init(rootViewControllerNoWrapping rootViewController: UIViewController) {
        super.init(rootViewController: ContainerController(contentController: rootViewController))
        commonInit()
    }

    /// init
    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        commonInit()
    }

    /// init
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// 初始化
    @objc
    open func commonInit() {}

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        super.delegate = self
        super.setNavigationBarHidden(true, animated: false)
    }

    /// delegate
    override open var delegate: UINavigationControllerDelegate? {
        get {
            return super.delegate
        }
        set {
            rt_delegate = newValue
        }
    }

    /// setNavigationBarHidden
    override open func setNavigationBarHidden(_: Bool, animated _: Bool) {}

    /// pushViewController
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        setUpFullscreenPopGestureRecognizer()
        if !viewControllers.isEmpty {
            let currentLast = viewControllers.last.map(rt_safeUnwrap(_:))
            super.pushViewController(rt_safeWrap(viewController, viewController.rt_navigationBarClass(), useSystemBackBarButtonItem, currentLast?.navigationItem.backBarButtonItem, currentLast?.navigationItem.title ?? currentLast?.title), animated: animated)
        } else {
            super.pushViewController(rt_safeWrap(viewController, viewController.rt_navigationBarClass()), animated: animated)
        }
    }

    /// popViewController
    @discardableResult
    override open func popViewController(animated: Bool) -> UIViewController? {
        return super.popViewController(animated: animated).map(rt_safeUnwrap(_:))
    }

    /// popToRootViewController
    @discardableResult
    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        return super.popToRootViewController(animated: animated)?.map(rt_safeUnwrap(_:))
    }

    /// popToViewController
    @discardableResult
    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if
            let controllerToPop = super.viewControllers.first(where: {
                rt_safeUnwrap($0) === viewController
            })
        {
            return super.popToViewController(controllerToPop, animated: animated)?.map(rt_safeUnwrap(_:))
        }
        return nil
    }

    /// setViewControllers
    override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers.enumerated().map {
            if self.useSystemBackBarButtonItem, $0.offset > 0 {
                let previous = viewControllers[$0.offset - 1]
                return rt_safeWrap($0.element, $0.element.rt_navigationBarClass(), self.useSystemBackBarButtonItem, previous.navigationItem.backBarButtonItem, previous.navigationItem.title ?? previous.title)
            } else {
                return rt_safeWrap($0.element, $0.element.rt_navigationBarClass())
            }
        }, animated: animated)
    }

    /// shouldAutorotate
    override open var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? super.shouldAutorotate
    }

    /// supportedInterfaceOrientations
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    /// preferredInterfaceOrientationForPresentation
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }

    /// responds(to:)
    override open func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return rt_delegate?.responds(to: aSelector) ?? false
    }

    /// forwardingTarget
    override open func forwardingTarget(for _: Selector!) -> Any? {
        return rt_delegate
    }

    // MARK: Public Methods

    /// removeViewController
    @objc
    open func removeViewController(_ viewController: UIViewController) {
        removeViewController(viewController, animated: false)
    }

    /// removeViewController:animated:
    @objc
    open func removeViewController(_ viewController: UIViewController, animated: Bool) {
        var controllers = viewControllers
        if
            let removeIndex = controllers.firstIndex(where: {
                rt_safeUnwrap($0) === viewController
            })
        {
            controllers.remove(at: removeIndex)
            super.setViewControllers(controllers, animated: animated)
        }
    }

    /// pushViewController with completion
    @objc
    open func pushViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping ((Bool) -> Void)) {
        self.completion?(false)
        self.completion = completion
        pushViewController(viewController, animated: animated)
    }

    /// popViewController with completion
    @discardableResult @objc
    open func popViewController(animated: Bool, completion: @escaping ((Bool) -> Void)) -> UIViewController? {
        self.completion?(false)
        self.completion = completion
        let vc = popViewController(animated: animated)
        if vc != nil {
            self.completion?(true)
            self.completion = nil
        }
        return vc
    }

    /// popToRootViewController with completion
    @discardableResult @objc
    open func popToRootViewController(animated: Bool, completion: @escaping ((Bool) -> Void)) -> [UIViewController]? {
        self.completion?(false)
        self.completion = completion
        let vcs = popToRootViewController(animated: animated)
        if !(vcs?.isEmpty ?? true) {
            self.completion?(true)
            self.completion = nil
        }
        return vcs
    }

    /// popToViewController with completion
    @discardableResult @objc
    open func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping ((Bool) -> Void)) -> [UIViewController]? {
        self.completion?(false)
        self.completion = completion
        let vcs = popToViewController(viewController, animated: animated)
        if !(vcs?.isEmpty ?? true) {
            self.completion?(true)
            self.completion = nil
        }
        return vcs
    }
}

// MARK: - UINavigationControllerDelegate

extension RootNavigationController: UINavigationControllerDelegate {
    /// navigationController willShow
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        assert(viewController is ContainerController, "must is ContainerController")
        let isRoot = viewController === navigationController.viewControllers.first
        let controller = rt_safeUnwrap(viewController)
        if !isRoot, controller.isViewLoaded {
            let hasSetLeftItem = controller.navigationItem.leftBarButtonItem != nil
            if hasSetLeftItem, !controller.rt_hasSetInteractivePop {
                controller.rt_disableInteractivePop = true
            } else if !controller.rt_hasSetInteractivePop {
                controller.rt_disableInteractivePop = false
            }
            installsLeftBarButtonItemIfNeeded(for: controller)
        }
        rt_delegate?.navigationController?(navigationController, willShow: controller, animated: animated)
    }

    /// navigationController didShow
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        assert(viewController is ContainerController, "must is ContainerController")
        let isRoot = viewController === navigationController.viewControllers.first
        let controller = rt_safeUnwrap(viewController)

        // fix #258 https://github.com/rickytan/RTRootNavigationController/issues/258
        // animated 为 NO 时的时序不太对，手动触发 viewDidLoad
        if !animated {
            _ = controller.view
        }

        if controller.rt_disableInteractivePop {
            fullscreenPopGestureRecognizer.delegate = nil
            fullscreenPopGestureRecognizer.isEnabled = false
        } else {
            fullscreenPopGestureRecognizer.delegate = fullscreenPopGestureRecognizerDelegate
            fullscreenPopGestureRecognizer.isEnabled = !isRoot
        }

        RootNavigationController.attemptRotationToDeviceOrientation()
        rt_delegate?.navigationController?(navigationController, didShow: controller, animated: animated)
        if animated {
            DispatchQueue.main.async {
                self.completion?(true)
                self.completion = nil
                rt_updateStatusBarAppearance(controller)
            }
        } else {
            completion?(true)
            completion = nil
            rt_updateStatusBarAppearance(controller, animated: false)
        }
    }

    /// navigationControllerSupportedInterfaceOrientations
    public func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        return rt_delegate?.navigationControllerSupportedInterfaceOrientations?(navigationController) ?? .all
    }

    /// navigationControllerPreferredInterfaceOrientationForPresentation
    public func navigationControllerPreferredInterfaceOrientationForPresentation(_ navigationController: UINavigationController) -> UIInterfaceOrientation {
        return rt_delegate?.navigationControllerPreferredInterfaceOrientationForPresentation?(navigationController) ?? .portrait
    }

    /// navigationController interactionControllerFor
    public func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let transitioning = rt_delegate?.navigationController?(navigationController, interactionControllerFor: animationController) {
            return transitioning
        }
        if let animation = animationController as? RTViewControllerAnimatedTransitioning {
            return animation.rt_interactiveTransitioning
        }
        return nil
    }

    /// navigationController animationControllerFor
    public func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if case .push = operation {
            fullscreenPopGestureRecognizer.delegate = nil
            fullscreenPopGestureRecognizer.isEnabled = false
        }
        if let transitioning = rt_delegate?.navigationController?(navigationController, animationControllerFor: operation, from: fromVC, to: toVC) {
            return transitioning
        }
        return operation == .push ? toVC.rt_animatedTransitioning : fromVC.rt_animatedTransitioning
    }
}

// MARK: - FullscreenPopGestureRecognizer

extension RootNavigationController {
    /// 设置全屏手势
    private func setUpFullscreenPopGestureRecognizer() {
        guard
            let gesture = interactivePopGestureRecognizer,
            let gestureView = gesture.view,
            !(gestureView.gestureRecognizers ?? []).contains(fullscreenPopGestureRecognizer),
            let target = rt_gestureTarget(gesture)
        else { return }
        fullscreenPopGestureRecognizerDelegate.navigationController = self
        let sel = NSSelectorFromString("handleNavigationTransition:")
        fullscreenPopGestureRecognizer.maximumNumberOfTouches = 1
        fullscreenPopGestureRecognizer.delegate = fullscreenPopGestureRecognizerDelegate
        fullscreenPopGestureRecognizer.addTarget(target, action: sel)
        gestureView.addGestureRecognizer(fullscreenPopGestureRecognizer)
        gesture.isEnabled = false
    }

    /// 设置自定义代理
    public final func setCustomFullscreenPopGestureRecognizerDelegate(_ delegate: FullscreenPopGestureRecognizerDelegateCustomizable) {
        fullscreenPopGestureRecognizerDelegate = delegate
        setUpFullscreenPopGestureRecognizer()
    }
}

// MARK: - Methods

extension RootNavigationController {
    /// 返回
    @objc
    private func onBack(_: AnyObject) {
        popViewController(animated: true)
    }

    /// 设置返回按钮
    final func installsLeftBarButtonItemIfNeeded(for viewController: UIViewController) {
        let isRoot = viewController === viewControllers.first.map(rt_safeUnwrap(_:))
        let hasSetLeftItem = viewController.navigationItem.leftBarButtonItem != nil
        if !isRoot, !useSystemBackBarButtonItem, !hasSetLeftItem, !viewController.rt_prefersNavigationBarHidden {
            if viewController.responds(to: #selector(NavigationItemCustomizable.rt_customBackItem(_:action:))) {
                viewController.navigationItem.leftBarButtonItem = (viewController as NavigationItemCustomizable).rt_customBackItem!(self, action: #selector(onBack(_:)))
            } else {
                let backTitle = NSLocalizedString("Back", comment: "")
                viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: backTitle, style: .plain, target: self, action: #selector(onBack(_:)))
            }
        }
    }
}

// swiftlint:enable line_length identifier_name
