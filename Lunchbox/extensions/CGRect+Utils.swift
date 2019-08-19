//
//  CGRect+Utils.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/14/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

extension CGRect {
  
  func subtractFromNearestHorizonalSide(rect: CGRect) -> CGRect {
    // Find how much r1 overlaps r2
    let intersection = self.intersection(rect)
  
    // If they don't intersect, just return r1. No subtraction to be done
    guard intersection.size != .zero else { return self }
    
    let xEdge = (abs(rect.maxX - minX) < abs(maxX - rect.minX)) ? CGRectEdge.minXEdge : .maxXEdge
    let (_, result) = divided(atDistance: intersection.size.width, from: xEdge)
    return result
  }
}
