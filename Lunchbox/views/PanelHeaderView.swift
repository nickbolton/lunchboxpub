//
//  PanelHeaderView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/12/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class PanelHeaderView: NiblessView {

  private let iconImage: UIImage
  private let titleLocalizedKey: String
  private let panelIxResponder: PanelIxResponder

  private let sideMargins: CGFloat = 10.0
  
  init(iconImage: UIImage, titleLocalizedKey: String, panelIxResponder: PanelIxResponder) {
    self.iconImage = iconImage
    self.titleLocalizedKey = titleLocalizedKey
    self.panelIxResponder = panelIxResponder
    super.init(frame: .zero)
    bindCloseButtonInteraction()
  }

  private lazy var iconImageView: UIImageView = {
    return UIImageView(image: iconImage)
  }()
  
  private let handleView = UIView()
  private let titleLabel = UILabel()
  
  private lazy var closeButton: UIButton = {
    let button = UIButton()
    let image = UIImage(named: "close-circle")
    button.setImage(image, for: .normal)
    return button
  }()
  
  private let dividerView = UIView()
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(iconImageView)
    addSubview(handleView)
    addSubview(titleLabel)
    addSubview(closeButton)
    addSubview(dividerView)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainIconImageView()
    constrainHandleView()
    constrainTitleLabel()
    constrainCloseButton()
    constrainDividerView()
  }
  
  private func constrainIconImageView() {
    guard let image = iconImageView.image else { return }
    iconImageView.layout(size: image.size)
    iconImageView.alignLeft(offset: sideMargins)
    iconImageView.centerY()
  }
  
  private func constrainHandleView() {
    let size = CGSize(width: 80.0, height: 6.0)
    let topSpace: CGFloat = 6.0
    handleView.layout(size: size)
    handleView.alignTop(offset: topSpace)
    handleView.centerX()
    handleView.layer.cornerRadius = size.height / 2.0
  }
  
  private func constrainTitleLabel() {
    titleLabel.alignLeading(toTrailingOf: iconImageView, offset: sideMargins)
    titleLabel.centerY(to: iconImageView)
  }
  
  private func constrainCloseButton() {
    closeButton.layout(size: UIButton.minTappableSize)
    closeButton.alignImageRight(width: UIButton.minTappableDimension, offset: -sideMargins)
    closeButton.centerY()
  }
  
  private func constrainDividerView() {
    let height: CGFloat = 1.0
    dividerView.layout(height: height)
    dividerView.expandWidth()
    dividerView.alignBottom()
  }
  
  // MARK: Binders
  
  private func bindCloseButtonInteraction() {
    closeButton.addTarget(self, action: #selector(handleCloseButtonTapped), for: .touchUpInside)
  }
  
  @objc private func handleCloseButtonTapped() {
    guard let panelView = superview as? PanelView else { return }
    panelIxResponder.closePanel(panelView)
  }
  
  // MARK: Text Styles
  
  private var titleStyle: TextStyle {
    let font = UIFont.systemFont(ofSize: 24.0, weight: .medium)
    let textColor = Design.shared.panelTitleColor
    let descriptor = TextDescriptor(text: titleLocalizedKey.localized(), font: font, textColor: textColor, kerning: 0.35)
    return TextStyle(textDescriptors: [descriptor])
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    dividerView.backgroundColor = Design.shared.panelDividerColor
    titleLabel.attributedText = titleStyle.attributedString
    handleView.backgroundColor = Design.shared.panelHandleColor
  }
}
