//
//  Environment.swift
//  Lunchbox
//
//  Created by Nick Bolton on 1/15/19.
//  Copyright © 2019 Pixelbleed, LLC. All rights reserved.
//

import UIKit

class Environment: NSObject {

    static let shared = Environment()
    private override init () { super.init() }

    public enum Location: String {
        case development = "Debug"
        case production  = "Release"
    }
    
    var location = Location.development
    
    var isDevelopment: Bool { return location == .development }
    var isProduction: Bool { return location == .production }
}
