//
//  Group.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/21/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

struct AddedBlock {
  let blockItem: BlockItem
  let position: Int
}

struct Group: Codable, Equatable, Hashable {
  
  static let minWidth: CGFloat = 274.0
  
  let id: String
  private (set) var frame = CGRect(origin: .zero, size: CGSize(width: Group.minWidth, height: Group.minWidth))
  var blocks = [Block]() { didSet { updateBlockMap() } }
  
  private var blockMap = [String: Block]()
  
  var isEmpty: Bool { return blocks.count <= 0 }
  
  mutating func update(frame: CGRect) {
    self.frame = frame.halfPointAligned
  }
  
  enum CodingKeys: CodingKey {
    case id, frame, blocks
  }

  init() {
    self.id = UUID().uuidString
  }
  
  init(frame: CGRect) {
    self.id = UUID().uuidString
    self.frame = frame.halfPointAligned
  }

  init(block: Block) {
    self.id = UUID().uuidString
    self.blocks = [block]
  }
  
  mutating func initializeBlockMap() {
    updateBlockMap()
  }
  
  mutating func updateBlockMap() {
    blockMap = blocks.reduce([String: Block]()) { (acc, cur) -> [String: Block] in
      var acc = acc
      acc[cur.id] = cur
      return acc
    }
  }
  
  func block(withId id: String) -> Block? {
    return blockMap[id]
  }
  
  func blockItem(withId id: String) -> BlockItem? {
    guard let block = self.block(withId: id) else { return nil }
    return BlockItem(group: self, block: block)
  }
  
  func isTitleBlock(_ block: Block) -> Bool {
    let textBlocks = blocks.filter { $0.type.isText }
    return textBlocks.first == block
  }
  
  @discardableResult
  mutating func addBlock(type: BlockType, at position: Int?) -> AddedBlock {
    let block = BlockFactory().buildBlock(type: type)
    return add(block: block, at: position)
  }
  
  @discardableResult
  mutating func add(block: Block, at position: Int?) -> AddedBlock {
    var addedPosition = 0
    if let pos = position, pos >= 0, pos < blocks.count {
      // add it at the designated position of the target group
      blocks.insert(block, at: pos)
      addedPosition = pos
    } else {
      // add it to the end of the target group
      addedPosition = blocks.count
      blocks.append(block)
    }
    let blockItem = BlockItem(group: self, block: block)
    return AddedBlock(blockItem: blockItem, position: addedPosition)
  }

  mutating func delete(block: Block) {
    if let blockIndex = blocks.firstIndex(of: block) {
      blocks.remove(at: blockIndex)
      // ensure there's a title block
      if (blocks.filter { $0.type.isText }).count <= 0 {
        let block = BlockFactory().buildBlock(type: .label)
        if blocks.count > 0 {
          blocks.insert(block, at: 0)
        } else {
          blocks.append(block)
        }
      }
    }
  }

  static func == (lhs: Group, rhs: Group) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}
