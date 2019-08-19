//
//  HPLayout.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 12/21/18.
//

import Foundation

public struct HPLayout: Codable, Equatable, Inspectable {
    public let key: String
    public var constraints: [HPConstraint]
    
    public var isSizeConstraining: Bool {
        return (constraints.filter {
            ($0.type == .width || $0.type == .height) && $0.isContentConstrained
        }).first?.isContentConstrained ?? false
    }
    
    public init(key: String, constraints: [HPConstraint]) {
        self.key = key
        self.constraints = constraints
    }
    
    public var isDefaultLayout: Bool {
        let types = Set(constraints.map { $0.type })
        return types.count == 4 && types.contains(.width) && types.contains(.height) &&
                ((types.contains(.top) && types.contains(.left)) ||
                (types.contains(.top) && types.contains(.right)) ||
                (types.contains(.top) && types.contains(.centerX)) ||
                (types.contains(.bottom) && types.contains(.left)) ||
                (types.contains(.bottom) && types.contains(.right)) ||
                (types.contains(.bottom) && types.contains(.centerX)) ||
                (types.contains(.centerY) && types.contains(.left)) ||
                (types.contains(.centerY) && types.contains(.right)) ||
                (types.contains(.centerY) && types.contains(.centerX)))
    }
    
    public func isEqualWithProportionality(to: HPLayout) -> Bool {
        guard constraints.count == to.constraints.count else { return false }
        for idx in 0..<constraints.count {
            let c1 = constraints[idx]
            let c2 = to.constraints[idx]
            if c1 != c2 || c1.isProportional != c2.isProportional {
                return false
            }
        }
        return true
    }
    
    public static func == (lhs: HPLayout, rhs: HPLayout) -> Bool {
        return lhs.key == rhs.key &&
            lhs.constraints == rhs.constraints
    }
}
