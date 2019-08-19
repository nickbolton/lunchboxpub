//
//  DocumentRootView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/20/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class DocumentRootView: NiblessView {
  
  private let headerContainer = UIView()
  private let footerContainer = UIView()
  private let footerTopContainer = UIView()
  let canvasContainer = UIView()
  
  let sidebarButton: ToolButton = {
    let button = ToolButton()
    let image = UIImage(named: "sidebar")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  private let navigateContainer: UIView = {
    let view = UIView()
    view.applyHeaderItemStyle()
    return view
  }()
  
  let navigateBackwardButton: ToolButton = {
    let button = ToolButton(innerCornerRadius: 0.0)
    let image = UIImage(named: "chevron-left")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()

  let navigateForwardButton: ToolButton = {
    let button = ToolButton(innerCornerRadius: 0.0)
    let image = UIImage(named: "chevron-right")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  let addressBarButton: ToolButton = {
    let button = ToolButton()
    button.applyHeaderItemStyle()
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    return button
  }()
  
  let navigateUpwardButton: ToolButton = {
    let button = ToolButton(innerSize: .zero, innerCornerRadius: 0.0)
    let image = UIImage(named: "corner-left-up")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  let playButton: ToolButton = {
    let button = ToolButton(innerSize: CGSize(width: 34.0, height: 34.0), innerCornerRadius: 10.0)
    let image = UIImage(named: "play")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  let zoomButton: ToolButton = {
    let button = ToolButton()
    button.applyHeaderItemStyle()
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    return button
  }()
  
  let zoomOutButton: ToolButton = {
    let button = ToolButton(innerSize: CGSize(width: 26.0, height: 26.0), innerCornerRadius: 13.0)
    let image = UIImage(named: "minus")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()

  let zoomInButton: ToolButton = {
    let button = ToolButton(innerSize: CGSize(width: 26.0, height: 26.0), innerCornerRadius: 13.0)
    let image = UIImage(named: "plus")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  let undoButton: ToolButton = {
    let button = ToolButton(innerSize: CGSize(width: 40.0, height: 40.0), innerCornerRadius: 20.0)
    let image = UIImage(named: "undo")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  let redoButton: ToolButton = {
    let button = ToolButton(innerSize: CGSize(width: 40.0, height: 40.0), innerCornerRadius: 20.0)
    let image = UIImage(named: "redo")?.withRenderingMode(.alwaysTemplate)
    button.setImage(image, for: .normal)
    return button
  }()
  
  private let toolContainer: UIView = {
    let view = UIView()
    view.clipsToBounds = true
    return view
  }()
  
  let addBlockButton: ToolButton = {
    let button = ToolButton(innerSize: .zero, innerCornerRadius: 0.0)
    let image = UIImage(named: "block-button-dark")
    button.setImage(image, for: .normal)
    return button
  }()
  
  let addLinkButton: ToolButton = {
    let button = ToolButton(innerSize: .zero, innerCornerRadius: 0.0)
    let image = UIImage(named: "link-button-dark")
    button.setImage(image, for: .normal)
    return button
  }()
  
  let markupButton: ToolButton = {
    let button = ToolButton(innerSize: .zero, innerCornerRadius: 0.0)
    let image = UIImage(named: "pencil-button-dark")
    button.setImage(image, for: .normal)
    return button
  }()
  
  let addPropertyButton: ToolButton = {
    let button = ToolButton(innerSize: .zero, innerCornerRadius: 0.0)
    let image = UIImage(named: "property-button-dark")
    button.setImage(image, for: .normal)
    return button
  }()
  
  let arrowButton: ToolButton = {
    let button = ToolButton(innerSize: .zero, innerCornerRadius: 0.0)
    let image = UIImage(named: "arrow-button-dark")
    button.setImage(image, for: .normal)
    return button
  }()
  
  var addressTitle = "" { didSet { addressBarButton.setTitle(addressTitle, for: .normal) } }
  var zoomLevel: Float = 100.0 { didSet { updateZoomLevelLabel() } }
  
  private let headerHeight: CGFloat = 61.0
  private let footerHeight: CGFloat = 61.0
  private let headerItemHeight: CGFloat = 44.0
  private let headerItemSpacing: CGFloat = 8.0
  private let toolItemSpacing: CGFloat = 19.0
  
  private var footerHeightConstraint: NSLayoutConstraint!
  private var navigateContainerLeftConstraint: NSLayoutConstraint!
  private var zoomButtonRightConstraint: NSLayoutConstraint!
  
  // MARK: View Hierarchy Construction
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(headerContainer)
    addSubview(footerContainer)
    footerContainer.addSubview(footerTopContainer)
    addSubview(canvasContainer)
    headerContainer.addSubview(sidebarButton)
    headerContainer.addSubview(navigateContainer)
    navigateContainer.addSubview(navigateBackwardButton)
    navigateContainer.addSubview(navigateForwardButton)
    headerContainer.addSubview(addressBarButton)
    addressBarButton.addSubview(navigateUpwardButton)
    addressBarButton.addSubview(playButton)
    headerContainer.addSubview(zoomButton)
    zoomButton.addSubview(zoomOutButton)
    zoomButton.addSubview(zoomInButton)
    footerTopContainer.addSubview(undoButton)
    footerTopContainer.addSubview(redoButton)
    footerTopContainer.addSubview(toolContainer)
    toolContainer.addSubview(addBlockButton)
    toolContainer.addSubview(addLinkButton)
    toolContainer.addSubview(markupButton)
    toolContainer.addSubview(addPropertyButton)
    toolContainer.addSubview(arrowButton)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainHeaderContainer()
    constrainFooterContainer()
    constrainFooterTopContainer()
    constrainCanvasContainer()
    constrainSidebarButton()
    constrainNavigateContainer()
    constrainNavigateBackwardButton()
    constrainNavigateForwardButton()
    constrainAddressBarButton()
    constrainNavigateUpwardButton()
    constrainPlayButton()
    constrainZoomButton()
    constrainZoomOutButton()
    constrainZoomInButton()
    constrainUndoButton()
    constrainRedoButton()
    constrainToolContainer()
    constrainAddBlockButton()
    constrainAddLinkButton()
    constrainMarkupButton()
    constrainAddPropertyButton()
    constrainArrowButton()
  }
  
  private func constrainHeaderContainer() {
    headerContainer.expandWidth()
    #if os(iOS)
    headerContainer.alignTop()
    #else
    headerContainer.alignSafeAreaTop()
    #endif
    headerContainer.layout(height: headerHeight)
  }
  
  private func constrainFooterContainer() {
    footerContainer.expandWidth()
    footerContainer.alignBottom()
    footerHeightConstraint = footerContainer.layout(height: safeRegionInsets.bottom + footerHeight)
  }
  
  private func constrainFooterTopContainer() {
    let height: CGFloat = 61.0
    footerTopContainer.layout(height: height)
    footerTopContainer.expandWidth()
    footerTopContainer.alignTop()
  }
  
  private func constrainCanvasContainer() {
    canvasContainer.expandWidth()
    canvasContainer.alignTop(toBottomOf: headerContainer)
    canvasContainer.alignBottom(toTopOf: footerContainer)
  }
  
  private func constrainSidebarButton() {
    let width: CGFloat = 68.0
    sidebarButton.layout(width: width)
    sidebarButton.layout(height: headerItemHeight)
    sidebarButton.alignLeft(offset: headerItemSpacing)
    sidebarButton.alignBottom(offset: -headerItemSpacing)
  }
  
  private func constrainNavigateContainer() {
    let width: CGFloat = 98.0
    navigateContainer.layout(width: width)
    navigateContainer.layout(height: headerItemHeight)
    navigateContainerLeftConstraint = navigateContainer.alignLeft()
    navigateContainer.alignBottom(offset: -headerItemSpacing)
  }
  
  private func constrainNavigateBackwardButton() {
    let width: CGFloat = 48.0
    navigateBackwardButton.alignLeft()
    navigateBackwardButton.layout(width: width)
    navigateBackwardButton.expandHeight()
  }
  
  private func constrainNavigateForwardButton() {
    let width: CGFloat = 48.0
    navigateForwardButton.alignRight()
    navigateForwardButton.layout(width: width)
    navigateForwardButton.expandHeight()
  }
  
  private func constrainAddressBarButton() {
    addressBarButton.layout(height: headerItemHeight)
    addressBarButton.alignBottom(offset: -headerItemSpacing)
    addressBarButton.alignLeft(toRightOf: navigateForwardButton, offset: headerItemSpacing)
    addressBarButton.alignRight(toLeftOf: zoomButton, offset: -headerItemSpacing)
  }
  
  private func constrainNavigateUpwardButton() {
    navigateUpwardButton.alignLeft()
    navigateUpwardButton.layout(size: UIButton.minTappableSize)
    navigateUpwardButton.centerY()
  }
  
  private func constrainPlayButton() {
    playButton.alignRight()
    playButton.layout(size: UIButton.minTappableSize)
    playButton.centerY()
  }
  
  private func constrainZoomButton() {
    let width: CGFloat = 148.0
    zoomButton.alignBottom(offset: -headerItemSpacing)
    zoomButtonRightConstraint = zoomButton.alignRight()
    zoomButton.layout(width: width)
    zoomButton.layout(height: headerItemHeight)
  }
  
  private func constrainZoomOutButton() {
    zoomOutButton.layout(size: UIButton.minTappableSize)
    zoomOutButton.centerY()
    zoomOutButton.alignLeft()
  }
  
  private func constrainZoomInButton() {
    zoomInButton.layout(size: UIButton.minTappableSize)
    zoomInButton.centerY()
    zoomInButton.alignRight()
  }
  
  private func constrainUndoButton() {
    let leftSpace: CGFloat = 18.0
    undoButton.alignLeft(offset: leftSpace)
    undoButton.centerY()
    undoButton.layout(size: UIButton.minTappableSize)
  }
  
  private func constrainRedoButton() {
    let leftSpace: CGFloat = 6.0
    redoButton.alignLeft(toRightOf: undoButton, offset: leftSpace)
    redoButton.centerY()
    redoButton.layout(size: UIButton.minTappableSize)
  }
  
  private func constrainToolContainer() {
    let height: CGFloat = 49.0
    toolContainer.centerX()
    toolContainer.layout(height: height)
    toolContainer.alignBottom()
  }
  
  private func constrainAddBlockButton() {
    let imageSize = addBlockButton.image(for: .normal)?.size ?? .zero
    addBlockButton.alignLeft()
    addBlockButton.alignTop()
    addBlockButton.layout(width: UIButton.minTappableDimension)
    addBlockButton.layout(height: imageSize.height)
  }
  
  private func constrainAddLinkButton() {
    let imageSize = addBlockButton.image(for: .normal)?.size ?? .zero
    addLinkButton.alignLeft(toRightOf: addBlockButton, offset: toolItemSpacing)
    addLinkButton.alignTop()
    addLinkButton.layout(width: UIButton.minTappableDimension)
    addLinkButton.layout(height: imageSize.height)
  }
  
  private func constrainMarkupButton() {
    let imageSize = addBlockButton.image(for: .normal)?.size ?? .zero
    markupButton.alignLeft(toRightOf: addLinkButton, offset: toolItemSpacing)
    markupButton.alignTop()
    markupButton.layout(width: UIButton.minTappableDimension)
    markupButton.layout(height: imageSize.height)
  }
  
  private func constrainAddPropertyButton() {
    let imageSize = addBlockButton.image(for: .normal)?.size ?? .zero
    addPropertyButton.alignLeft(toRightOf: markupButton, offset: toolItemSpacing)
    addPropertyButton.alignTop()
    addPropertyButton.layout(width: UIButton.minTappableDimension)
    addPropertyButton.layout(height: imageSize.height)
  }
  
  private func constrainArrowButton() {
    let imageSize = addBlockButton.image(for: .normal)?.size ?? .zero
    arrowButton.alignLeft(toRightOf: addPropertyButton, offset: toolItemSpacing)
    arrowButton.alignTop()
    arrowButton.layout(width: UIButton.minTappableDimension)
    arrowButton.layout(height: imageSize.height)
    arrowButton.alignRight()
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    backgroundColor = Design.shared.canvasBackgroundColor
    headerContainer.backgroundColor = Design.shared.headerBackgroundColor
    headerContainer.layer.apply(sketchShadow: Design.shared.headerShadow)
    footerContainer.backgroundColor = Design.shared.headerBackgroundColor
    addressBarButton.setTitleColor(Design.shared.toolControlTintColor, for: .normal)
    addressBarButton.setTitleColor(Design.shared.toolControlTintColor.color(withAlpha: 0.5), for: .highlighted)
    zoomButton.setTitleColor(Design.shared.toolControlTintColor, for: .normal)
    zoomButton.setTitleColor(Design.shared.toolControlTintColor.color(withAlpha: 0.5), for: .highlighted)
    
    let imageSuffix = Design.shared.isDarkMode ? "dark" : "light"
    addBlockButton.setImage(UIImage(named: "block-button-\(imageSuffix)"), for: .normal)
    addBlockButton.setImage(UIImage(named: "block-button-\(imageSuffix)"), for: .highlighted)
    addLinkButton.setImage(UIImage(named: "link-button-\(imageSuffix)"), for: .normal)
    addLinkButton.setImage(UIImage(named: "link-button-\(imageSuffix)"), for: .highlighted)
    markupButton.setImage(UIImage(named: "pencil-button-\(imageSuffix)"), for: .normal)
    markupButton.setImage(UIImage(named: "pencil-button-\(imageSuffix)"), for: .highlighted)
    addPropertyButton.setImage(UIImage(named: "property-button-\(imageSuffix)"), for: .normal)
    addPropertyButton.setImage(UIImage(named: "property-button-\(imageSuffix)"), for: .highlighted)
    arrowButton.setImage(UIImage(named: "arrow-button-\(imageSuffix)"), for: .normal)
    arrowButton.setImage(UIImage(named: "arrow-button-\(imageSuffix)"), for: .highlighted)
  }
  
  // MARK: Helpers
  
  private func updateZoomLevelLabel() {
    let title = NumberFormatter.localizedString(from: NSNumber(value: zoomLevel), number: .percent)
    zoomButton.setTitle(title, for: .normal)
  }
  
  // MARK: Constraints
  
  override func updateConstraints() {
    super.updateConstraints()
    updateNavigateContainerConstraints()
    updateZoomButtonConstraints()
  }
  
  private func updateNavigateContainerConstraints() {
    let leftSpaceFactor: CGFloat = 0.1649916248
    let leftSpace = leftSpaceFactor * bounds.width
    navigateContainerLeftConstraint?.constant = leftSpace
  }
  
  private func updateZoomButtonConstraints() {
    let rightSpaceFactor: CGFloat = 0.1289782245
    let rightSpace = rightSpaceFactor * bounds.width
    zoomButtonRightConstraint?.constant = -rightSpace
  }
}
