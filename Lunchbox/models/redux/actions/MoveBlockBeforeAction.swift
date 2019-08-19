//
//  MoveBlockBeforeAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/1/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct MoveBlockBeforeAction: Action, ReducingAction {

  let blockItem: BlockItem
  let targetItem: BlockItem
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    guard var updatedPosition = page.blockPosition(for: targetItem) else { return result }
    guard var sourceGroup = page.group(withId: blockItem.group.id) else { return result }
    guard var targetGroup = page.group(withId: targetItem.group.id) else { return result }
    
    if sourceGroup == targetGroup {
      // first check if source position changed within the same group
      guard let sourcePosition = page.blockPosition(for: blockItem) else { return result }
      guard updatedPosition.position != sourcePosition.position + 1 else { return result }
    }
    
    sourceGroup.delete(block: blockItem.block)
    GroupResizer.resize(group: &sourceGroup)
    page.update(group: sourceGroup)
    if targetGroup == sourceGroup {
      targetGroup = sourceGroup
    }
    updatedPosition = page.blockPosition(for: targetItem)!
    let addedBlock = targetGroup.add(block: blockItem.block, at: updatedPosition.position)
    GroupResizer.resize(group: &targetGroup)
    page.update(group: targetGroup)
    page.repositionGroups()
    page.lastAddedBlock = addedBlock.blockItem
    page.lastAddedPosition = BlockPosition(group: addedBlock.blockItem.group, position: addedBlock.position)
    result.updatePage(page: page)
    return result
  }
}
