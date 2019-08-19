//
//  AppDelegate.swift
//  Lunchbox
//
//  Created by Nick Bolton on 3/31/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WireframeManager.shared.registerWireframe(LunchboxWireframe())
        let result = LunchboxBootstrap().initialize(app: application, launchOptions: launchOptions)
        window = result.window
        return result.ok
    }
}

