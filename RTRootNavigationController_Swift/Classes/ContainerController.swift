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

/// 包装容器层
@objc(RTContainerController)
public final class ContainerController: UIViewController {
    /// 真实Push VC
    @objc
    public let contentViewController: UIViewController

    /// 独立 NavigationController 容器
    private var containerNavigationController: ContainerNavigationController?

    /// init
    internal init(
        contentController controller: UIViewController
    ) {
        contentViewController = controller
        super.init(nibName: nil, bundle: nil)
        addChild(contentViewController)
        contentViewController.didMove(toParent: self)
    }

    /// init
    internal init(
        controller: UIViewController,
        navigationBarClass: UINavigationBar.Type? = nil,
        placeholderController yesOrNo: Bool = false,
        backBarButtonItem backItem: UIBarButtonItem? = nil,
        backTitle: String? = nil
    ) {
        contentViewController = controller
        super.init(nibName: nil, bundle: nil)
        // not work while push to a hideBottomBar view controller, give up
        /*
         self.edgesForExtendedLayout = UIRectEdgeAll;
         self.extendedLayoutIncludesOpaqueBars = YES;
         */
        let containerNavigationController = ContainerNavigationController(navigationBarClass: navigationBarClass, toolbarClass: nil)
        if yesOrNo {
            let placeholder = UIViewController()
            placeholder.view.backgroundColor = .white
            placeholder.title = backTitle
            placeholder.navigationItem.backBarButtonItem = backItem
            containerNavigationController.viewControllers = [placeholder, controller]
        } else {
            containerNavigationController.viewControllers = [controller]
        }
        addChild(containerNavigationController)
        containerNavigationController.didMove(toParent: self)
        self.containerNavigationController = containerNavigationController
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var debugDescription: String {
        return "<\(type(of: self)): \(self) contentViewController: \(contentViewController)>"
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        // fix contentViewController.view.backgroundColor
        view.backgroundColor = contentViewController.view.backgroundColor ?? .white
        if let containerNavigationController = containerNavigationController {
            containerNavigationController.view.backgroundColor = view.backgroundColor
            containerNavigationController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.addSubview(containerNavigationController.view)
            containerNavigationController.view.frame = view.bounds
        } else {
            contentViewController.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            view.addSubview(contentViewController.view)
            contentViewController.view.frame = view.bounds
        }
    }

    // MARK: - override methods

    /// becomeFirstResponder
    override public func becomeFirstResponder() -> Bool {
        return contentViewController.becomeFirstResponder()
    }

    /// canBecomeFirstResponder
    override public var canBecomeFirstResponder: Bool {
        return contentViewController.canBecomeFirstResponder
    }

    /// preferredStatusBarStyle
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return contentViewController.preferredStatusBarStyle
    }

    /// prefersStatusBarHidden
    override public var prefersStatusBarHidden: Bool {
        return contentViewController.prefersStatusBarHidden
    }

    /// preferredStatusBarUpdateAnimation
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return contentViewController.preferredStatusBarUpdateAnimation
    }

    /// childForScreenEdgesDeferringSystemGestures
    override public var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        return contentViewController
    }

    /// preferredScreenEdgesDeferringSystemGestures
    override public var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return contentViewController.preferredScreenEdgesDeferringSystemGestures
    }

    /// prefersHomeIndicatorAutoHidden
    override public var prefersHomeIndicatorAutoHidden: Bool {
        return contentViewController.prefersHomeIndicatorAutoHidden
    }

    /// childForHomeIndicatorAutoHidden
    override public var childForHomeIndicatorAutoHidden: UIViewController? {
        return contentViewController
    }

    /// shouldAutorotate
    override public var shouldAutorotate: Bool {
        return contentViewController.shouldAutorotate
    }

    /// supportedInterfaceOrientations
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return contentViewController.supportedInterfaceOrientations
    }

    /// preferredInterfaceOrientationForPresentation
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return contentViewController.preferredInterfaceOrientationForPresentation
    }

    // MARK: - contentViewController methods

    /// hidesBottomBarWhenPushed
    override public var hidesBottomBarWhenPushed: Bool {
        get {
            return contentViewController.hidesBottomBarWhenPushed
        }
        set {
            contentViewController.hidesBottomBarWhenPushed = newValue
        }
    }

    /// title
    override public var title: String? {
        get {
            return contentViewController.title
        }
        set {
            contentViewController.title = newValue
        }
    }

    /// tabBarItem
    override public var tabBarItem: UITabBarItem! {
        get {
            return contentViewController.tabBarItem
        }
        set {
            contentViewController.tabBarItem = newValue
        }
    }

    /// rt_animatedTransitioning
    override public var rt_animatedTransitioning: UIViewControllerAnimatedTransitioning? {
        return contentViewController.rt_animatedTransitioning
    }
}

// swiftlint:enable line_length
