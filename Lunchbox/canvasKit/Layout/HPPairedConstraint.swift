//
//  HPPairedConstraint.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 12/24/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import UIKit
#endif

class HPPairedConstraint: NSObject {

    private (set) public var sourceAttribute: NSLayoutConstraint.Attribute
    private (set) public var targetAttribute: NSLayoutConstraint.Attribute
    private (set) public var constant: CGFloat
    private (set) public var scale: CGFloat

    init(sourceAttribute: NSLayoutConstraint.Attribute,
         targetAttribute: NSLayoutConstraint.Attribute,
         constant: CGFloat,
         scale: CGFloat) {
        self.sourceAttribute = sourceAttribute
        self.targetAttribute = targetAttribute
        self.constant = constant.halfPointAligned
        self.scale = scale
        super.init()
    }
    
    func applyConstraint(source: UIView, target: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: source,
                                  attribute: sourceAttribute,
                                  relatedBy: .equal,
                                  toItem: target,
                                  attribute: targetAttribute,
                                  multiplier: 1.0,
                                  constant: constant * scale)
    }
}
