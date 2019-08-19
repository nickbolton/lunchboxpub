//
//  ReducingAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/11/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation
import ReSwift

protocol ReducingAction {
  func reduce(state: AppState) -> AppState
}
