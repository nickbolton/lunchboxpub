//
//  HPSimpleConstraint.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 12/24/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit

class HPSimpleConstraint: NSObject {

    private (set) public var constant: CGFloat
    private (set) public var attribute: NSLayoutConstraint.Attribute
    private (set) public var isSafeArea: Bool
    private (set) public var scale: CGFloat

    init(attribute: NSLayoutConstraint.Attribute, constant: CGFloat, scale: CGFloat, isSafeArea: Bool) {
        self.attribute = attribute
        self.constant = constant.halfPointAligned
        self.isSafeArea = isSafeArea
        self.scale = scale
        super.init()
    }

    func applyConstraint(to view: UIView) -> NSLayoutConstraint {
        switch attribute {
        case .width, .height:
            return NSLayoutConstraint(item: view,
                                      attribute: attribute,
                                      relatedBy: .equal,
                                      toItem: nil,
                                      attribute: .notAnAttribute,
                                      multiplier: 1.0,
                                      constant: constant * scale)
        default:
            assert(view.superview != nil, "View must be part of a view hierarchy.")
            #if os(iOS)
            return NSLayoutConstraint(item: view,
                                      attribute: attribute,
                                      relatedBy: .equal,
                                      toItem: isSafeArea ? view.superview?.safeAreaLayoutGuide : view.superview,
                                      attribute: attribute,
                                      multiplier: 1.0,
                                      constant: constant * scale)
            #elseif os(macOS)
            return NSLayoutConstraint(item: view,
                                      attribute: attribute,
                                      relatedBy: .equal,
                                      toItem: view.superview,
                                      attribute: attribute,
                                      multiplier: 1.0,
                                      constant: constant * scale)
            #endif
        }
    }
}
