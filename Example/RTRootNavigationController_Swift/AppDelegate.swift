//
//  AppDelegate.swift
//  RTRootNavigationController_Swift
//
//  Created by wuzhe on 06/20/2022.
//  Copyright (c) 2022 wuzhe. All rights reserved.
//

import RTRootNavigationController_Swift
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        rt_setCustomizableStatusBarAppearance()
        window?.rootViewController = RootNavigationController(rootViewControllerNoWrapping: RedController())
        window?.makeKeyAndVisible()
        return true
    }
}
