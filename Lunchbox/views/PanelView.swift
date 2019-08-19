//
//  PanelView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/12/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

protocol PanelIxResponder {
  func closePanel(_ panelView: PanelView)
}

class PanelView: NiblessView {

  private let titleLocalizedKey: String
  private let iconImage: UIImage
  private let panelIxResponder: PanelIxResponder
  
  init(iconImage: UIImage, titleLocalizedKey: String, panelIxResponder: PanelIxResponder) {
    self.titleLocalizedKey = titleLocalizedKey
    self.iconImage = iconImage
    self.panelIxResponder = panelIxResponder
    super.init(frame: .zero)
  }

  lazy var headerView = PanelHeaderView(iconImage: iconImage,
                                        titleLocalizedKey: titleLocalizedKey,
                                        panelIxResponder: panelIxResponder)
  
  private var effectView: UIVisualEffectView?
  
  // MARK: View Hierarchy
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(headerView)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainHeaderView()
  }
  
  private func constrainHeaderView() {
    let height: CGFloat = 55.0
    headerView.expandWidth()
    headerView.alignTop()
    headerView.layout(height: height)
  }
  
  // MARK: Helpers
  
  private func applyEffectView() {
    effectView?.removeFromSuperview()
    let blurView = UIVisualEffectView(effect: Design.shared.blurEffect)
    effectView = blurView
    insertSubview(blurView, at: 0)
    blurView.expand()
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    backgroundColor = Design.shared.panelBackgroundColor
    applyEffectView()
  }
}
