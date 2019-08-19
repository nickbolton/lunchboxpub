//
//  UIView+Design.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/22/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

extension UIView {
    func applyHeaderItemStyle() {
        clipsToBounds = true
        layer.cornerRadius = 10.0
    }
}
