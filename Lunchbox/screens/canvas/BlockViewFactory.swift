//
//  BlockViewFactory.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/22/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

struct BlockViewFactory {
  
  func buildBlockView(block: Block, in group: Group) -> NiblessView {
    switch block.type {
    case .spacer:
      return NiblessView()
    case .label, .body, .labelBody:
      return BlockGroupedTextView(text: block.textOrDefault, isTitle: group.isTitleBlock(block))
    case .divider:
      return NiblessView()
    case .action:
      return NiblessView()
    case .link:
      return NiblessView()
    case .list:
      return NiblessView()
    case .media:
      return NiblessView()
    case .property:
      return NiblessView()
    case .displayProperty:
      return NiblessView()
    case .changeProperty:
      return NiblessView()
    case .toggle:
      return NiblessView()
    }
  }
  
  func height(for block: Block, in group: Group, contentWidth: CGFloat, isEditingText: Bool) -> CGFloat {
    switch block.type {
    case .spacer:
      return block.height
    case .label, .body, .labelBody:
      return BlockGroupedTextView.height(for: block, isTitle: group.isTitleBlock(block), isEditing: isEditingText, contentWidth: contentWidth)
    case .divider:
      return 0.0
    case .action:
      return 0.0
    case .link:
      return 0.0
    case .list:
      return 0.0
    case .media:
      return 0.0
    case .property:
      return 0.0
    case .displayProperty:
      return 0.0
    case .changeProperty:
      return 0.0
    case .toggle:
      return 0.0
    }
  }
}
