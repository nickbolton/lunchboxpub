//
//  UpdateGroupAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/5/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct UpdateGroupAction: Action, ReducingAction {
  
  let group: Group
  var reposition = false
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    page.update(group: group)
    if reposition {
      result.lastActionPositionDelta = page.reposition(movedGroup: group)
    }
    result.updatePage(page: page)
    return result
  }
}
