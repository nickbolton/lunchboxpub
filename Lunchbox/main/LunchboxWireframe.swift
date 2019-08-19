//
//  LunchboxWireframe.swift
//  Lunchbox
//
//  Created by Nick Bolton on 1/15/19.
//  Copyright © 2019 Pixelbleed, LLC. All rights reserved.
//

import UIKit
import MobileKit

class LunchboxWireframe: Wireframe {

    private var mainViewController = MainViewController()

    override func wireApplication(window: UIWindow) {
        super.wireApplication(window: window)
        window.rootViewController = mainViewController
    }
}
