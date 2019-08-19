//
//  Swift+Utils.swift
//  HappyPath
//
//  Created by Nick Bolton on 1/10/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation

public protocol Inspectable {
    func propertyNames() -> [String]
    func iterateProperties(_ handler: (_ name: String, _ value: Any, _ idx: Int, _ count: Int) -> Void)
    func deepIterateProperties(_ handler: (_ name: String, _ value: Any, _ idx: Int, _ count: Int) -> Void)
}

public extension Inspectable
{
    func propertyNames() -> [String] {
        return Mirror(reflecting: self).children.compactMap { $0.label }
    }
    
    func iterateProperties(_ handler: (_ name: String, _ value: Any, _ idx: Int, _ count: Int) -> Void) {
        let type: Mirror = Mirror(reflecting:self)
        let count = type.children.count
        var idx = 0
        for child in type.children {
            handler(child.label!, child.value, idx, count)
            idx += 1
        }
    }
    
    func deepIterateProperties(_ handler: (_ name: String, _ value: Any, _ idx: Int, _ count: Int) -> Void) {
        let type: Mirror = Mirror(reflecting:self)
        let count = type.children.count
        var idx = 0
        for child in type.children {
            handler(child.label!, child.value, idx, count)
            if let inspectable = child.value as? Inspectable {
                inspectable.deepIterateProperties(handler)
            }
            idx += 1
        }
    }
}
