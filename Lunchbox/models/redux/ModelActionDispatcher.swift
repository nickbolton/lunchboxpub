//
//  ModelAction.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/10/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import Foundation
import ReSwift

public protocol ActionDispatcher {
  
  func dispatch(_ action: Action)
}

extension Store: ActionDispatcher {}
