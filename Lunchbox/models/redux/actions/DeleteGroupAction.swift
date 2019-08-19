//
//  DeleteGroupAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 6/30/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct DeleteGroupAction: Action, ReducingAction {

  let group: Group
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    page.delete(group: group)
    result.updatePage(page: page)
    return result
  }
}
