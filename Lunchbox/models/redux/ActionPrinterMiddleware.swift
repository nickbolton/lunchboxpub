//
//  ModelAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/10/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation
import ReSwift
import MobileKit

let printActionMiddleware: Middleware<AppState> = { dispatch, getState in
  return { next in
    return { action in
//      let msgBefore = "\n\n\(action), Action dispatched."
//      Logger.shared.debug(msgBefore)
      next(action)
//      let msgAfter = "new state: \n\(String(describing: getState()))\n\n"
//      Logger.shared.debug(msgAfter)
      return
    }
  }
}
