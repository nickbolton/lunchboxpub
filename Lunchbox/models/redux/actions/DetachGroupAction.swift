//
//  DetachGroupAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/17/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct DetachGroupAction: Action, ReducingAction {
  
  let group: Group
  let from: Group?
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    guard page.group(withId: group.id) == nil else { return result }
    
    if var targetGroup = from {
      for block in group.blocks {
        targetGroup.delete(block: block)
      }
      GroupResizer.resize(group: &targetGroup)
      page.update(group: targetGroup)
    }
    
    page.add(group: group)
    result.updatePage(page: page)
    return result
  }
}
