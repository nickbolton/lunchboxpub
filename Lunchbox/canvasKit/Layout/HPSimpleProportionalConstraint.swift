//
//  HPSimpleProportionalConstraint.swift
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

class HPSimpleProportionalConstraint: NSObject {
  
  private (set) public var proportionalityConstant: CGFloat
  private (set) public var attribute: NSLayoutConstraint.Attribute
  private (set) public var isSafeArea: Bool
  private (set) public var screenSize: CGSize
  private (set) public var scale: CGFloat
  
  init(attribute: NSLayoutConstraint.Attribute,
       proportionalityConstant: CGFloat,
       isSafeArea: Bool,
       scale: CGFloat,
       screenSize: CGSize) {
    self.attribute = attribute
    self.proportionalityConstant = proportionalityConstant
    self.isSafeArea = isSafeArea
    self.screenSize = screenSize
    self.scale = scale
    super.init()
  }
  
  func applyConstraint(to view: UIView) -> NSLayoutConstraint {
    assert(view.superview != nil || attribute == .width || attribute == .height, "View must be part of a view hierarchy.")
    let yConstant = (proportionalityConstant * screenSize.height * scale).halfPointAligned
    let xConstant = (proportionalityConstant * screenSize.width * scale).halfPointAligned
    
    #if os(iOS)
    let safeAreaItem = isSafeArea ? view.superview?.safeAreaLayoutGuide : view.superview
    #elseif os(macOS)
    let safeAreaItem = view.superview
    #endif
    
    switch attribute {
    case .top, .centerY, .bottom:
      return NSLayoutConstraint(item: view,
                                attribute: attribute,
                                relatedBy: .equal,
                                toItem: safeAreaItem,
                                attribute: attribute,
                                multiplier: 1.0,
                                constant: yConstant)
    case .height:
      return NSLayoutConstraint(item: view,
                                attribute: attribute,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: yConstant)
    case .left, .leading, .centerX, .right, .trailing:
      return NSLayoutConstraint(item: view,
                                attribute: attribute,
                                relatedBy: .equal,
                                toItem: safeAreaItem,
                                attribute: attribute,
                                multiplier: 1.0,
                                constant: yConstant)
    case .width:
      return NSLayoutConstraint(item: view,
                                attribute: attribute,
                                relatedBy: .equal,
                                toItem: nil,
                                attribute: .notAnAttribute,
                                multiplier: 1.0,
                                constant: xConstant)
    default:
      assert(false, "Layout attribute not supported: \(attribute)")
    }
    return NSLayoutConstraint(item: view, attribute: .notAnAttribute, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 0.0)
  }
}
