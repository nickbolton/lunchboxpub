//
//  LunchboxLocker.swift
//  Lunchbox
//
//  Created by Nick Bolton on 1/15/19.
//  Copyright © 2019 Pixelbleed, LLC. All rights reserved.
//

import UIKit
import MobileKit

class LunchboxLocker: BaseLocker {

    static let shared = LunchboxLocker()
    private init() {
        super.init(name: NSStringFromClass(LunchboxLocker.self))
        setDefaults()
        LockerManager.shared.registerLocker(self)
        if !hasPreviouslyRun {
            logOut()
            hasPreviouslyRun = true
        }
    }
    
    required init(name: String) {
        super.init(name: name)
    }
    
    func logOut() {
    }
    
    private let hasPreviouslyRunKey = "hasPreviouslyRun"
    var hasPreviouslyRun: Bool {
        get {
            return UserDefaults.standard.bool(forKey: hasPreviouslyRunKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasPreviouslyRunKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func wipeData() {
        super.wipeData()
    }
    
    func handleLogOut() {
        wipeData()
    }
    
    // MARK: Helpers
    
    private func setDefaults() {
        UserDefaults.standard.register(defaults:
            [:])
    }
}
