//
//  AddNewBlockAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 6/25/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct AddNewBlockAction: Action, ReducingAction {

  let blockType: BlockType
  let group: Group?
  let position: Int?
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    if var group = group {
      let addedBlock = group.addBlock(type: blockType, at: position)
      var group = addedBlock.blockItem.group
      GroupResizer.resize(group: &group)
      page.update(group: group)
      page.repositionGroups()
      result.selectedGroup = page.group(withId: group.id)
    } else {
      var group = Group()
      page.add(group: group)
      group.addBlock(type: blockType, at: nil)
      GroupResizer.resize(group: &group)
      page.update(group: group)
      page.reposition(addedGroup: group)
      result.selectedGroup = page.group(withId: group.id)
    }
    result.updatePage(page: page)
    return result
  }  
}
