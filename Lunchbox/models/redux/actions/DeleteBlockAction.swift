//
//  DeleteBlockAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 6/30/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct DeleteBlockAction: Action, ReducingAction {

  let blockItem: BlockItem
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    guard var group = page.group(withId: blockItem.group.id) else { return result }
    group.delete(block: blockItem.block)
    GroupResizer.resize(group: &group)
    page.update(group: group)
    result.updatePage(page: page)
    return result
  }
}
