//
//  Page.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/21/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

fileprivate let groupSpacing: CGFloat = 32.0

fileprivate struct ColumnResult {
  let column: [Group]
  let rect: CGRect
  let emptyAreas: [CGRect]
  let overlaps: Bool
  
  func findRectInEmptyAreas(forRect rect: CGRect) -> CGRect? {
    for emptyRect in emptyAreas {
      if emptyRect.intersects(rect), emptyRect.height >= rect.height {
        if rect.maxY > emptyRect.maxY {
          let origin = CGPoint(x: rect.minX, y: emptyRect.maxY - rect.height - groupSpacing)
          return CGRect(origin: origin, size: rect.size)
        } else {
          let origin = CGPoint(x: rect.minX, y: emptyRect.minY + groupSpacing)
          return CGRect(origin: origin, size: rect.size)
        }
      }
    }
    return nil
  }
}

struct Page: Codable {
  let id: String
  let parentPath: [String]
  var title = ""
  var notes = ""
  var tags = [Tag]()
  var groups = [Group]() { didSet { updateGroupMap() } }
  
  private var groupMap = [String: Group]()
  
  var lastAddedBlock: BlockItem?
  var lastAddedPosition: BlockPosition?
  
  enum CodingKeys: CodingKey {
    case id, parentPath, title, notes, tags, groups
  }
  
  init() {
    self.id = UUID().uuidString
    self.parentPath = []
  }
  
  mutating func initializeGroupMap() {
    for idx in 0..<groups.count {
      groups[idx].initializeBlockMap()
    }
    updateGroupMap()
  }
  
  private mutating func updateGroupMap() {
    groupMap = groups.reduce([String: Group]()) { (acc, cur) -> [String: Group] in
      var acc = acc
      acc[cur.id] = cur
      return acc
    }
  }
    
  func group(withId id: String) -> Group? {
    return groupMap[id]
  }
  
  func intersectingRegion(with rect: CGRect, excluding: Group? = nil) -> CGRect {
    let filteredGroups = groups.filter { $0 != excluding }
    let bounds = groupBounds(groups: filteredGroups)
    let intersection = rect.intersection(bounds)
    return intersection.size != .zero ? intersection : .zero
  }
  
  func blockPosition(for blockItem: BlockItem) -> BlockPosition? {
    guard let groupIndex = groups.firstIndex(of: blockItem.group) else { return nil }
    guard let blockIndex = groups[groupIndex].blocks.firstIndex(of: blockItem.block) else { return nil }
    return BlockPosition(group: blockItem.group, position: blockIndex)
  }
  
  mutating func updateBlock(_ blockItem: BlockItem) {
    guard let groupIndex = groups.firstIndex(of: blockItem.group) else { return }
    guard let blockIndex = groups[groupIndex].blocks.firstIndex(of: blockItem.block) else { return }
    groups[groupIndex].blocks[blockIndex] = blockItem.block
  }
  
  mutating func update(group: Group) {
    guard let groupIndex = groups.firstIndex(of: group) else { return }
    groups[groupIndex] = group
  }
  
  mutating func add(group: Group) {
    groups.append(group)
  }
  
  mutating func delete(group: Group) {
    if let groupIndex = groups.firstIndex(of: group) {
      groups.remove(at: groupIndex)
    }
  }
}

extension Page {
  // MARK: Repositioning
  
  mutating func reposition(addedGroup: Group) {
    let columnResult = findGroupColumn(groups: groups, target: addedGroup)
    var column = columnResult.column.filter { $0 != addedGroup }
    column = column.sorted { $0.frame.minY < $1.frame.minY }
    if columnResult.rect != .zero {
      var updatedGroup = addedGroup
      let origin = CGPoint(x: addedGroup.frame.minX, y: columnResult.rect.maxY + groupSpacing)
      updatedGroup.update(frame: CGRect(origin: origin, size: updatedGroup.frame.size))
      update(group: updatedGroup)
    }
  }

  @discardableResult
  mutating func reposition(movedGroup: Group) -> CGVector {
    var positionDelta = CGVector.zero
    let columnResult = findGroupColumn(groups: groups, target: movedGroup)
    var column = columnResult.column.filter { $0 != movedGroup }
    column = column.sorted { $0.frame.minY < $1.frame.minY }
    if columnResult.rect != .zero && columnResult.overlaps {
      var updatedGroup = movedGroup
      
      if let availableRect = columnResult.findRectInEmptyAreas(forRect: updatedGroup.frame) {
        updatedGroup.update(frame: availableRect)
        update(group: updatedGroup)
      } else if movedGroup.frame.midY >= columnResult.rect.midY {
        let origin = CGPoint(x: movedGroup.frame.minX, y: columnResult.rect.maxY + groupSpacing)
        updatedGroup.update(frame: CGRect(origin: origin, size: updatedGroup.frame.size))
        update(group: updatedGroup)
      } else {
        let origin = CGPoint(x: movedGroup.frame.minX, y: columnResult.rect.minY - groupSpacing - movedGroup.frame.height)
        updatedGroup.update(frame: CGRect(origin: origin, size: updatedGroup.frame.size))
        update(group: updatedGroup)
        positionDelta.dy = max(-origin.y, 0.0)
        if positionDelta.dy > 0.0 {
          offsetAllGroups(by: positionDelta)
        }
      }
    }
    return positionDelta
  }
  
  private mutating func offsetAllGroups(by offset: CGVector) {
    var updatedGroups = groups
    for idx in 0..<updatedGroups.count {
      updatedGroups[idx].update(frame: updatedGroups[idx].frame.offsetBy(dx: offset.dx, dy: offset.dy))
    }
    groups = updatedGroups
  }

  private func findGroupColumn(groups: [Group], target: Group) -> ColumnResult {
    var result = [[Group]]()
    groups.forEach { group in
      guard result.count > 0 else {
        // create first bucket
        result.append([group])
        return
      }
      var foundBucket = false
      for i in 0..<result.count {
        guard !foundBucket else { break }
        var bucket = result[i]
        for g in bucket {
          if areGroupsInSameColumn(group1: g, group2: group) {
            bucket.append(group)
            result[i] = bucket
            foundBucket = true
            break
          }
        }
      }
      if !foundBucket {
        // create new bucket
        result.append([group])
      }
    }
    for column in result {
      if column.contains(target) {
        let filteredColumn = column.filter { $0 != target }
        let overlaps = (filteredColumn.filter { $0.frame.intersects(target.frame) }).count > 0
        let emptyAreas = buildEmptyAreas(column: filteredColumn)
        return ColumnResult(column: column, rect: groupBounds(groups: filteredColumn), emptyAreas: emptyAreas, overlaps: overlaps)
      }
    }
    // should never get here
    return ColumnResult(column: [], rect: .zero, emptyAreas: [], overlaps: false)
  }
  
  private func buildEmptyAreas(column: [Group]) -> [CGRect] {
    let sorted = column.sorted { $0.frame.minY < $1.frame.minY }
    guard sorted.count > 1 else { return [] }
    var result = [CGRect]()
    var lastGroup = sorted[0]
    for i in 1..<sorted.count {
      let group = sorted[i]
      let minX = min(lastGroup.frame.minX, group.frame.minX)
      let maxX = max(lastGroup.frame.maxX, group.frame.maxX)
      let rect = CGRect(x: minX,
                        y: lastGroup.frame.maxY,
                        width: maxX - minX,
                        height: max(group.frame.minY - lastGroup.frame.maxY, 0.0))
      result.append(rect)
      lastGroup = group
    }
    return result
  }
  
  private func groupBounds(groups: [Group]) -> CGRect {
    guard groups.count > 0 else { return .zero }
    var result = groups[0].frame
    groups.forEach { result = result.union($0.frame) }
    return result
  }
  
  mutating func repositionGroups() {
    let groupSpacing: CGFloat = 32.0
    let columnBuckets = buildColumnBuckets(groups: groups)
    var updatedGroups = [Group]()
    for col in 0..<columnBuckets.count {
      var column = columnBuckets[col].sorted { $0.frame.minY < $1.frame.minY }
      guard column.count > 1 else {
        updatedGroups.append(column[0])
        continue
      }
      let firstGroup = column[0]
      let minY = firstGroup.frame.minY - groupSpacing
      var maxY = firstGroup.frame.maxY + groupSpacing
      updatedGroups.append(firstGroup)
      for i in 1..<column.count {
        var group = column[i]
        if doesOverlapVerticalRegion(group: group, minY: minY, maxY: maxY) {
          let origin = CGPoint(x: group.frame.minX, y: maxY + groupSpacing)
          group.update(frame: CGRect(origin: origin, size: group.frame.size))
        }
        maxY = group.frame.maxY + groupSpacing
        updatedGroups.append(group)
      }
    }
    groups = updatedGroups
  }
  
  private func buildColumnBuckets(groups: [Group]) -> [[Group]] {
    var result = [[Group]]()
    groups.forEach { group in
      guard result.count > 0 else {
        // create first bucket
        result.append([group])
        return
      }
      var foundBucket = false
      for i in 0..<result.count {
        guard !foundBucket else { break }
        var bucket = result[i]
        for g in bucket {
          if areGroupsInSameColumn(group1: g, group2: group) {
            bucket.append(group)
            result[i] = bucket
            foundBucket = true
            break
          }
        }
      }
      if !foundBucket {
        // create new bucket
        result.append([group])
      }
    }
    return result
  }
  
  private func areGroupsInSameColumn(group1: Group, group2: Group) -> Bool {
    return group1.frame.minX <= group2.frame.maxX && group1.frame.maxX >= group2.frame.minX
  }

  private func doesOverlapVerticalRegion(group: Group, minY: CGFloat, maxY: CGFloat) -> Bool {
    return group.frame.minY <= maxY && group.frame.maxY >= minY
  }
}

extension Page: Equatable, Hashable {
  
  static func == (lhs: Page, rhs: Page) -> Bool {
    return lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    id.hash(into: &hasher)
  }
}
