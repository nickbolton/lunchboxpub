//
//  BlocksPanelCell.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/30/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class BlocksPanelCell: NiblessCollectionCell {
  
  private let iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "block-body")
    return imageView
  }()
  
  private let textContainer = UIView()
  
  private let titleLabel = UILabel()
  
  private let descriptionLabel: UILabel = {
    let label = UILabel()
    label.alpha = 0.7
    return label
  }()
  
  var blockType = BlockType.spacer { didSet { setNeedsDisplay() } }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    layer.cornerRadius = 10.0
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    blockType = .spacer
  }
  
  // MARK: Text Styles
  
  private var titleStyle: TextStyle {
    let font = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    let descriptor = TextDescriptor(text: blockType.label, font: font, textColor: Design.shared.blockTextColor)
    return TextStyle(textDescriptors: [descriptor])
  }
  
  private var descriptionStyle: TextStyle {
    let font = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    let descriptor = TextDescriptor(text: blockType.description, font: font, textColor: Design.shared.blockTextColor)
    return TextStyle(textDescriptors: [descriptor])
  }
  
  // MARK: View Hierarchy Construction
  
  override func constructHierarchy() {
    super.constructHierarchy()
    contentView.addSubview(iconImageView)
    contentView.addSubview(textContainer)
    textContainer.addSubview(titleLabel)
    textContainer.addSubview(descriptionLabel)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainIconImageView()
    constrainTextContainer()
    constrainTitleLabel()
    constrainDescriptionLabel()
  }
  
  private func constrainIconImageView() {
    let leadingSpace: CGFloat = 9.0
    let size = iconImageView.image?.size ?? .zero
    iconImageView.layout(size: size)
    iconImageView.alignLeading(offset: leadingSpace)
    iconImageView.centerY()
  }
  
  private func constrainTextContainer() {
    let margin: CGFloat = 20.0
    textContainer.centerY()
    textContainer.alignLeading(toTrailingOf: iconImageView, offset: margin)
    textContainer.alignTrailing(offset: -margin)
  }
  
  private func constrainTitleLabel() {
    titleLabel.alignLeading()
    titleLabel.alignTop(for: titleStyle)
  }
  
  private func constrainDescriptionLabel() {
    let topSpace: CGFloat = 5.5
    descriptionLabel.alignLeading()
    descriptionLabel.alignBaseline()
    descriptionLabel.alignTop(for: descriptionStyle, toBaselineOf: titleLabel, offset: topSpace)
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    backgroundColor = Design.shared.panelItemColor
    titleLabel.attributedText = titleStyle.attributedString
    descriptionLabel.attributedText = descriptionStyle.attributedString
  }
}
