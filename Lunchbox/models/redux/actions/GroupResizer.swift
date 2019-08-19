//
//  GroupResizer.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/15/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

struct GroupResizer {
  
  static func resize(group: inout Group) {
    let size = GroupSizer().size(for: group, editingItem: nil)
    group.update(frame: CGRect(origin: group.frame.origin, size: size))
  }
}
