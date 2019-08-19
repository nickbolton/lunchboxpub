//
//  HPLayerConfig.swift
//  HappyPathKit
//
//  Created by Nick Bolton on 12/16/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//
import Foundation

public enum HPLayerType: Int, Codable, CaseIterable {
    case none
    case container
    
    public var isContainingType: Bool {
        switch self {
        case .container:
            return true
        default:
            return false
        }
    }
}

public struct HPLayerConfig: Codable {
    public var type: HPLayerType
    public var backgroundColor: HPColorValue?

    public init(type: HPLayerType) {
        self.type = type
    }
}
