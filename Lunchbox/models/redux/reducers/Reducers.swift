//
//  Reducers.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/10/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation
import ReSwift

struct Reducers {}

extension Reducers {
  
  public static func appStateReducer(action: Action, state: AppState?) -> AppState {
    if let replaceAppStateAction = action as? ReplaceAppStateAction {
      return replaceAppStateAction.appState
    }
    var state = state
    state?.lastActionPositionDelta = .zero
    let currentState = state ?? AppState(pages: [Page()])
    if let reducingAction = action as? ReducingAction {
      return reducingAction.reduce(state: currentState)
    }
    return currentState
  }
}
