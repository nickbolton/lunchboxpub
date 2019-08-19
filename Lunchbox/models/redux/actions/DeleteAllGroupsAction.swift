//
//  DeleteAllGroupsAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/14/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct DeleteAllGroupsAction: Action, ReducingAction {
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    page.groups = []
    result.updatePage(page: page)
    return result
  }
}
