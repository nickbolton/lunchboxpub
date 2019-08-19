//
//  HPLayoutFactory.swift
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

public struct HPLayoutFactory {
    static public func build(layer: HPLayer, scale: CGFloat, viewMap: [String: UIView]) -> HPViewLayout {
        var constraints = [HPViewConstraint]()
        let isSafeArea = layer.layout.constraints.filter { $0.type == .safeArea }.first != nil
        for c in layer.layout.constraints {
            switch c.type {
            case .top, .bottom, .height, .centerY,
                 .left, .right, .width, .centerX:
                guard !layer.isRootLayer else { continue }
                if let sourceView = viewMap[c.sourceID] {
                    constraints.append(HPViewConstraint(constraint: c, scale: scale, isSafeArea: isSafeArea, sourceView: sourceView))
                } else {
                    print("Error : No source view found with ID: \(c.sourceID)")
                }
            case .verticalSpacing, .verticalCenters, .horizontalSpacing, .horizontalCenters:
                if let sourceView = viewMap[c.sourceID] {
                    if let targetID = c.targetID {
                        if let targetView = viewMap[targetID] {
                            constraints.append(HPViewConstraint(constraint: c, scale: scale, isSafeArea: isSafeArea, sourceView: sourceView, targetView: targetView))
                        } else {
                            print("Error : No target view found with ID: \(targetID)")
                        }
                    } else {
                        print("Error : No constraint targetID: \(c)")
                    }
                } else {
                    print("Error : No source view found with ID: \(c.sourceID)")
                }
            default:
                break
            }
        }
        return HPViewLayout(constraints: constraints)
    }
    
    static public func defaultLayout(layer: HPLayer, scale: CGFloat, view: UIView, screenSize: CGSize) -> HPViewLayout {
        var constraints = [HPViewConstraint]()
        let frame = layer.frame
        constraints.append(HPViewConstraint(constraint: HPConstraint(sourceID: layer.id, type: .top, value: frame.minY), scale: scale, isSafeArea: true, sourceView: view))
        constraints.append(HPViewConstraint(constraint: HPConstraint(sourceID: layer.id, type: .left, value: frame.minX), scale: scale, isSafeArea: true, sourceView: view))
        constraints.append(HPViewConstraint(constraint: HPConstraint(sourceID: layer.id, type: .width, value: frame.width), scale: scale, isSafeArea: true, sourceView: view))
        constraints.append(HPViewConstraint(constraint: HPConstraint(sourceID: layer.id, type: .height, value: frame.height), scale: scale, isSafeArea: true, sourceView: view))
        return HPViewLayout(constraints: constraints)
    }
}
