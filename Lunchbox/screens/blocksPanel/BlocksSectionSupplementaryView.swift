//
//  BlocksSectionSupplementaryView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 6/1/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class BlocksSectionSupplementaryView: NiblessCollectionReusableView {

  private let titleLabel: UILabel = {
    let label = UILabel()
    return label
  }()
  
  var title: String? { didSet { setNeedsDisplay() } }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    title = ""
  }
  
  // MARK: View Hierarchy
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(titleLabel)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainTitleLabel()
  }
  
  private func constrainTitleLabel() {
    titleLabel.expand()
  }
  
  // MARK: Text Styles
  
  private var titleStyle: TextStyle {
    let font = UIFont.systemFont(ofSize: 24.0, weight: .bold)
    let text = title ?? ""
    let color = Design.shared.panelTitleColor
    let descriptor = TextDescriptor(text: text, font: font, textColor: color, kerning: 0.6)
    return TextStyle(textDescriptors: [descriptor])
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    titleLabel.attributedText = titleStyle.attributedString
  }
}
