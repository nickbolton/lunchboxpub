//
//  PromoteBlockToGroupAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/15/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct PromoteBlockToGroupAction: Action, ReducingAction {
  
  let block: Block
  let frame: CGRect
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    var group = Group()
    group.blocks = [block]
    group.update(frame: frame)
    GroupResizer.resize(group: &group)
    let heightDiff = group.frame.height - frame.height
    var updatedFrame = group.frame
    updatedFrame.origin.y -= heightDiff / 2.0
    group.update(frame: updatedFrame)
    page.add(group: group)
    page.lastAddedBlock = group.blockItem(withId: block.id)
    page.lastAddedPosition = BlockPosition(group: group, position: 0)
    result.updatePage(page: page)
    return result
  }
}
