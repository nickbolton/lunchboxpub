//
//  CanvasRootView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/21/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class CanvasRootView: NiblessView {
    
  private (set) lazy var canvasView: CanvasView = {
    let view = CanvasView()
    view.alwaysBounceVertical = true
    view.alwaysBounceHorizontal = true
    view.insetsLayoutMarginsFromSafeArea = false
    view.contentInsetAdjustmentBehavior = .never
    view.backgroundColor = .clear
    view.delaysContentTouches = false
    view.panGestureRecognizer.minimumNumberOfTouches = 2
    return view
  }()
      
  func setCanvasScale(_ scale: CGFloat) {
    canvasView.scale = scale
  }
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(canvasView)
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainCanvasView()
  }
  
  private func constrainCanvasView() {
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      canvasView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
      canvasView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
      canvasView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      canvasView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
      ])
  }  
}
