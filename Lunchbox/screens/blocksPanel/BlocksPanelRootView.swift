//
//  BlocksPanelRootView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/12/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class BlocksPanelRootView: PanelView {
  
  let collectionView: UICollectionView
    
  init(collectionView: UICollectionView, panelIxResponder: PanelIxResponder) {
    let image = UIImage(named: "blocks")!
    let titleKey = "blocks.panel.title"
    self.collectionView = collectionView
    super.init(iconImage: image, titleLocalizedKey: titleKey, panelIxResponder: panelIxResponder)
  }
  
  // MARK: View Hierarchy
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(collectionView)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainCollectionView()
  }
  
  private func constrainCollectionView() {
    let topSpace: CGFloat = 49.0
    let height: CGFloat = 290.0
    collectionView.expandWidth()
    collectionView.alignTop(toBottomOf: headerView, offset: topSpace)
    collectionView.layout(height: height)
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    collectionView.backgroundColor = .clear
  }
}
