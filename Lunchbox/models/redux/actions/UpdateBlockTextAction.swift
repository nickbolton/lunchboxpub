//
//  UpdateBlockTextAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/11/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation
import ReSwift

struct UpdateBlockTextAction: Action, ReducingAction {
  let blockItem: BlockItem
  
  func reduce(state: AppState) -> AppState {
    var result = state
    guard var page = state.selectedPage else { return result }
    page.updateBlock(blockItem)
    result.updatePage(page: page)
    return result
  }
}
