//
//  Block.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/21/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

enum BlockType: String, CaseIterable, Codable {
  
  // system types
  case spacer
  
  // simple types
  case label
  case body
  case labelBody
  case divider
  case action
  case link
  case list
  case media
  
  // data types
  case property
  case displayProperty
  case changeProperty
  case toggle
  
  var label: String {
    let prefix = "block.type.title."
    let key = prefix + rawValue
    return key.localized()
  }
  
  var description: String {
    let prefix = "block.type.description."
    let key = prefix + rawValue
    return key.localized()
  }
  
  var isText: Bool {
    switch self {
    case .label, .body, .labelBody:
      return true
    default:
      return false
    }
  }
  
  static let simpleTypes: [BlockType] = [.label, .labelBody, .body, .divider, .action, .link, .list, .media]
  static let dataTypes: [BlockType] = [.property, .displayProperty, .changeProperty, .toggle]
}

struct BlockItem: Equatable {
  let group: Group
  var block: Block
  
  static func == (lhs: BlockItem, rhs: BlockItem) -> Bool {
    return lhs.group == rhs.group
      && lhs.block == rhs.block
  }
}

struct BlockPosition: Equatable {
  let group: Group
  let position: Int
    
  static func == (lhs: BlockPosition, rhs: BlockPosition) -> Bool {
    return lhs.group == rhs.group
      && lhs.position == rhs.position
  }
}

struct Block: Codable, Equatable, Hashable {
  let id: String
  let type: BlockType
  var height: CGFloat
  var text = ""
  var mediaURL: String?
  
  enum CodingKeys: CodingKey {
    case id, type, height, text, mediaURL
  }
  
  var textOrDefault: String {
    if text.count > 0 {
      return text
    }
    return defaultText
  }

  var defaultText: String {
    get {
      switch type {
      case .label, .body, .labelBody:
        let keyPrefix = "block.text.type.default.text."
        let key = keyPrefix + type.rawValue
        return key.localized()
      default:
        return ""
      }
    }
  }
  
  init(type: BlockType, height: CGFloat = 0.0, text: String = "", mediaURL: String? = nil) {
    self.id = UUID().uuidString
    self.type = type
    self.text = text
    self.height = height
    self.mediaURL = mediaURL
  }
  
  func isContentEqual(to: Block) -> Bool {
    return text == to.text && mediaURL == to.mediaURL
  }
  
  static func == (lhs: Block, rhs: Block) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}
