//
//  MoveGroupBeforeAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/17/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct MoveGroupBeforeAction: Action, ReducingAction {
  
  let group: Group
  let targetItem: BlockItem
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard group.blocks.count > 0 else { return result }
    guard var page = state.selectedPage else { return result }
    guard var updatedPosition = page.blockPosition(for: targetItem) else { return result }
    guard var targetGroup = page.group(withId: targetItem.group.id) else { return result }
    
    page.delete(group: group)
    
    for block in group.blocks {
      targetGroup.delete(block: block)
    }
    
    updatedPosition = page.blockPosition(for: targetItem)!

    for block in group.blocks.reversed() {
      targetGroup.add(block: block, at: updatedPosition.position)
    }
    let lastBlock = group.blocks.last!
    let lastPosition = targetGroup.blocks.firstIndex(of: lastBlock)!
    GroupResizer.resize(group: &targetGroup)
    page.update(group: targetGroup)
    page.repositionGroups()
    page.lastAddedBlock = targetGroup.blockItem(withId: lastBlock.id)
    page.lastAddedPosition = BlockPosition(group: targetGroup, position: lastPosition)
    result.updatePage(page: page)
    return result
  }
}
