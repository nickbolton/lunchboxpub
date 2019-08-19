//
//  ToolButton.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/22/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class ToolButton: NiblessButton {
  
  private lazy var innerView: UIView = {
    let view = UIView()
    view.isUserInteractionEnabled = false
    view.layer.cornerRadius = innerCornerRadius
    view.clipsToBounds = true
    return view
  }()
  
  private let innerSize: CGSize
  private let innerCornerRadius: CGFloat
  
  override var isHighlighted: Bool { didSet { setNeedsDisplay() } }
  
  init(innerSize: CGSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), innerCornerRadius: CGFloat = 10.0) {
    self.innerSize = innerSize
    self.innerCornerRadius = innerCornerRadius
    super.init(frame: .zero)
  }
  
  // MARK: View Hierarchy Construction
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(innerView)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainInnerView()
  }
  
  private func constrainInnerView() {
    if innerSize.width == CGFloat.greatestFiniteMagnitude || innerSize.height == CGFloat.greatestFiniteMagnitude {
      innerView.alignLeft()
      innerView.alignRight(priority: .defaultHigh)
      innerView.alignTop()
      innerView.alignBottom(priority: .defaultHigh)
    } else {
      innerView.layout(size: innerSize)
      innerView.centerView()
    }
  }
  
  // MARK: End View Hierarchy Construction
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    alpha = isHighlighted ? 0.5 : 1.0
    tintColor = Design.shared.toolControlTintColor
    innerView.backgroundColor = Design.shared.toolControlBackgroundColor
  }
}
