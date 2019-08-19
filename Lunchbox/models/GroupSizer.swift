//
//  GroupSizer.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/16/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

struct GroupSizer {
  
  let sideMargins: CGFloat = 10.0
  let blockSpacing: CGFloat = 8.0

  func size(for group: Group, editingItem: BlockItem?) -> CGSize {
    let height = self.height(for: group, editingItem: editingItem)
    return CGSize(width: group.frame.width, height: height).halfPointAligned
  }
  
  func height(for group: Group, editingItem: BlockItem?) -> CGFloat {
    let minHeight: CGFloat = 69.0
    var result: CGFloat = 0.0
    let factory = BlockViewFactory()
    let contentWidth = group.frame.size.width - (2.0 * sideMargins)
    var lastBlock: Block?
    for b in group.blocks {
      var block = b
      if block == editingItem?.block {
        block = editingItem!.block
      }
      let isEditingText = (block == editingItem?.block)
      if lastBlock != nil {
        result += blockSpacing
      }
      result += factory.height(for: block, in: group, contentWidth: contentWidth, isEditingText: isEditingText)
      lastBlock = b
    }
    if lastBlock != nil && lastBlock != group.blocks.first {
      result += sideMargins
    }
    return max(result, minHeight).halfPointAligned
  }
}
