//
//  HandleView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/6/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class HandleView: NiblessView {
  
  init(position: GroupResizePosition) {
    self.position = position
    super.init(frame: .zero)
    backgroundColor = .white
    layer.borderColor = UIColor.black.color(withAlpha: 0.1).cgColor
    layer.borderWidth = 1.0
    layer.applySketchShadow(color: .black,
                            opacity: 0.2,
                            x: 0.0,
                            y: 1.0,
                            blur: 4.0,
                            spread: 0.0)
  }

  let position: GroupResizePosition
  
  // MARK: Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = frame.height / 2.0
  }
}
