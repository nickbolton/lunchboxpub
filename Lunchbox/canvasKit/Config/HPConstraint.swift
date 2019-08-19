//
//  HPConstraint.swift
//  LunchboxCanvasKit
//
//  Created by Nick Bolton on 12/21/18.
//

#if os(iOS)
import UIKit
#elseif os(macOS)
import UIKit
#endif

public struct HPConstraintType: OptionSet, Codable, Hashable {
  public let rawValue: Int
  public typealias RawValue = Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let right             = HPConstraintType(rawValue: 1 << 0)
  public static let width             = HPConstraintType(rawValue: 1 << 1)
  public static let left              = HPConstraintType(rawValue: 1 << 2)
  public static let bottom            = HPConstraintType(rawValue: 1 << 3)
  public static let height            = HPConstraintType(rawValue: 1 << 4)
  public static let top               = HPConstraintType(rawValue: 1 << 5)
  public static let centerX           = HPConstraintType(rawValue: 1 << 6)
  public static let centerY           = HPConstraintType(rawValue: 1 << 7)
  public static let verticalSpacing   = HPConstraintType(rawValue: 1 << 8)
  public static let horizontalSpacing = HPConstraintType(rawValue: 1 << 9)
  public static let verticalCenters   = HPConstraintType(rawValue: 1 << 10)
  public static let horizontalCenters = HPConstraintType(rawValue: 1 << 11)
  public static let safeArea          = HPConstraintType(rawValue: 1 << 12)
  
  public static let expand      = HPConstraintType.top.union(.bottom).union(.left).union(.right)
  public static let center      = HPConstraintType.centerY.union(.centerX)
  public static let topLeft     = HPConstraintType.top.union(.left)
  public static let topRight    = HPConstraintType.top.union(.right)
  public static let bottomLeft  = HPConstraintType.bottom.union(.left)
  public static let bottomRight = HPConstraintType.bottom.union(.right)
  
  public var isVertical: Bool {
    switch self {
    case .top, .bottom, .centerY, .height, .verticalSpacing, .verticalCenters:
      return true
    default:
      return false
    }
  }
  
  public var isHorizontal: Bool {
    return !isVertical && self != .safeArea
  }
  
  public var hashValue: Int { return rawValue.hashValue }
  
  public var sourceAttribute: NSLayoutConstraint.Attribute {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    case .centerY:
      return .centerY
    case .left:
      return .leading
    case .right:
      return .trailing
    case .centerX:
      return .centerX
    case .width:
      return .width
    case .height:
      return .height
    case .verticalSpacing:
      return .top
    case .horizontalSpacing:
      return .leading
    case .verticalCenters:
      return .centerY
    case .horizontalCenters:
      return .centerX
    default:
      return .notAnAttribute
    }
  }
  
  public var targetAttribute: NSLayoutConstraint.Attribute {
    switch self {
    case .top:
      return .top
    case .bottom:
      return .bottom
    case .centerY:
      return .centerY
    case .left:
      return .leading
    case .right:
      return .trailing
    case .centerX:
      return .centerX
    case .width:
      return .notAnAttribute
    case .height:
      return .notAnAttribute
    case .verticalSpacing:
      return .bottom
    case .horizontalSpacing:
      return .trailing
    case .verticalCenters:
      return .centerY
    case .horizontalCenters:
      return .centerX
    default:
      return .notAnAttribute
    }
  }
}

public struct HPConstraint: Codable, Hashable, Equatable {
  public let sourceID: String
  public let targetID: String?
  public let type: HPConstraintType
  public let value: CGFloat
  public let proportionalValue: CGFloat
  public let isProportional: Bool
  public let isContentConstrained: Bool
  
  public init(sourceID: String,
              targetID: String? = nil,
              type: HPConstraintType,
              value: CGFloat,
              proportionalValue: CGFloat = 0.0,
              isProportional: Bool = false,
              isContentConstrained: Bool = false) {
    self.sourceID = sourceID
    self.targetID = targetID
    self.type = type
    self.value = value
    self.proportionalValue = proportionalValue
    self.isProportional = isProportional
    self.isContentConstrained = isContentConstrained
  }
  
  public func hash(into hasher: inout Hasher) {
    hasher.combine(sourceID)
    hasher.combine(targetID)
    hasher.combine(type)
  }
  
  public static func == (lhs: HPConstraint, rhs: HPConstraint) -> Bool {
    return lhs.sourceID == rhs.sourceID &&
      lhs.targetID == rhs.targetID &&
      lhs.type == rhs.type
  }
}
