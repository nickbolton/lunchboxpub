//
//  PotentialLayer.swift
//  Canvas
//
//  Created by Nick Bolton on 12/10/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit

struct PotentialLayer: Hashable {
    let isInsideFrame: Bool
    let distance: CGFloat
    let layerId: String
    let canvasLocation: CGPoint
    let depth: UInt
    let siblingIndex: UInt
    let isSelected: Bool

    func hash(into hasher: inout Hasher) {
        layerId.hash(into: &hasher)
    }
}
