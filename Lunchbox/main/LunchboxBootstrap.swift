//
//  LunchboxBootstrap.swift
//  Lunchbox
//
//  Created by Nick Bolton on 1/15/19.
//  Copyright © 2019 Pixelbleed, LLC. All rights reserved.
//

import UIKit
import MobileKit
import AlamofireNetworkActivityLogger

class LunchboxBootstrap: Bootstrap {

    override func initialize(app: UIApplication,
                             launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Result {
        
        Environment.shared.location = Environment.Location(rawValue: (Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String ?? "")) ?? .development
        Design.shared.isDarkMode = true
        initializeLogger()
        initializeNetworkLogger()
        return super.initialize(app: app, launchOptions: launchOptions)
    }
    
    private func initializeNetworkLogger() {
        switch Environment.shared.location {
        case .development:
            NetworkActivityLogger.shared.level = .debug
            NetworkActivityLogger.shared.startLogging()
        case .production:
            NetworkActivityLogger.shared.level = .off
        }
    }
    
    private func initializeLogger() {
        switch Environment.shared.location {
        case .development:
            Logger.shared.logLevel = .verbose
        case .production:
            Logger.shared.logLevel = .error
        }
    }
}
