//
//  HPViewLayout.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 12/22/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import UIKit
#endif

public struct HPViewLayout {
    let constraints: [HPViewConstraint]
    public func applyLayout(screenSize: CGSize) {
        var layoutConstraints = [NSLayoutConstraint]()
        for c in constraints {
            layoutConstraints.append(c.applyConstraint(screenSize: screenSize))
        }
        NSLayoutConstraint.activate(layoutConstraints)
    }
}
