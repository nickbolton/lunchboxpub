//
//  HPPage.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 12/29/18.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import UIKit
#endif

public struct HPPage: Codable, Equatable, Hashable, Inspectable {
  public let id: String
  public var layers: [HPLayer]
  
  public init() {
    self.id = UUID().uuidString
    self.layers = []
  }
  
  public var flattened: [HPLayer] {
    var result = [HPLayer]()
    for layer in layers {
      result.append(contentsOf: layer.flattened)
    }
    return result
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  public func traverse(options: HPLayerTraversalOption = .deep, handler: (_ layer: HPLayer, _ parent: HPLayer?)->Bool) {
    for layer in layers {
      layer.traverse(options: options, handler: handler)
    }
  }
  
  public static func == (lhs: HPPage, rhs: HPPage) -> Bool {
    return lhs.id == rhs.id
  }
}
