//
//  BlockFactory.swift
//  Lunchbox
//
//  Created by Nick Bolton on 6/25/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

struct BlockFactory {

  func buildBlock(type: BlockType) -> Block {
    switch type {
    case .spacer:
      let defaultHeight: CGFloat = 20.0
      return Block(type: type, height: defaultHeight)
    default:
      return Block(type: type)
    }
  }
}
