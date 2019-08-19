//
//  MainRootView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 3/6/19.
//  Copyright © 2019 Pixelbleed, LLC. All rights reserved.
//

import UIKit
import MobileKit

class MainRootView: NiblessView {
  
  private let loaderView = LoaderView.loaderView()
  private let loaderContainer = UIView()
  
  // MARK: View Hierarchy Construction
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(loaderContainer)
  }

  override func activateConstraints() {
    super.activateConstraints()
    constrainLoaderContainer()
  }
  
  private func constrainLoaderContainer() {
    loaderContainer.expand()
  }
  
  // MARK: Helpers
  
  func showLoadingView() {
    loaderView.show(in: loaderContainer, ignoreInteractionEvents: false)
  }
  
  func hideLoadingView() {
    loaderView.hide(from: loaderContainer)
  }
}
