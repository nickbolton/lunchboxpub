//
//  Tag.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/22/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

struct Tag: Codable, Equatable, Hashable {
    let id: String
    let name: String
    
    static func == (lhs: Tag, rhs: Tag) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        id.hash(into: &hasher)
    }
}
