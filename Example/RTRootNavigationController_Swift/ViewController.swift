//
//  ViewController.swift
//  RTRootNavigationController_Swift
//
//  Created by wuzhe on 06/20/2022.
//  Copyright (c) 2022 wuzhe. All rights reserved.
//

import RTRootNavigationController_Swift
import UIKit

class RedController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        title = "red"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func touchesBegan(_: Set<UITouch>, with _: UIEvent?) {
        navigationController?.pushViewController(WhiteController(), animated: true)
    }
}

class WhiteController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "white"
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}

public extension UIViewController {
    @objc
    func rt_customBackItem(_ target: Any, action: Selector) -> UIBarButtonItem? {
        return UIBarButtonItem(title: "fuck", style: .plain, target: target, action: action)
    }
}
