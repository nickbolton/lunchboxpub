//
//  MoveBlockIntoGroupAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/4/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct MoveBlockIntoGroupAction: Action, ReducingAction {
  
  let blockItem: BlockItem
  let group: Group
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    guard var sourceGroup = page.group(withId: blockItem.group.id) else { return result }
    guard var targetGroup = page.group(withId: group.id) else { return result }
    sourceGroup.delete(block: blockItem.block)
    targetGroup.add(block: blockItem.block, at: nil)
    GroupResizer.resize(group: &sourceGroup)
    page.update(group: sourceGroup)
    if sourceGroup != targetGroup {
      GroupResizer.resize(group: &targetGroup)
      page.update(group: targetGroup)
    }
    result.updatePage(page: page)
    return result
  }
}
