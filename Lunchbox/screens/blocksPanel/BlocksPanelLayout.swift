//
//  BlocksPanelLayout.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/30/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class BlocksPanelLayout: GloballyCachingCollectionViewLayout {

  private let columnSpacing: CGFloat = 40.0
  private let rowSpacing: CGFloat = 10.0
  private let sectionYPos: CGFloat = 44.0
  private let rowCount = 4
  private let itemSize = CGSize(width: 358.0, height: 54.0)
  
  let sectionTitleKind = "sectionTitle"

  override init() {
    super.init()
    minContentSize.height = CGFloat(rowCount) * itemSize.height + (CGFloat(rowCount - 1) * rowSpacing) + sectionYPos
  }
  
  private func sectionStartingXPosition(at section: Int) -> CGFloat {
    var result: CGFloat = 0.0
    if section > 0 {
      for section in 0...section - 1 {
        guard let sectionArray = dataSourceProvider.dataSourceArray(at: section) else { continue }
        guard sectionArray.count > 0 else { continue }
        let lastIndexPath = IndexPath(item: sectionArray.count - 1, section: section)
        let lastRect = itemFrameInsideSection(at: lastIndexPath)
        result += lastRect.maxX + columnSpacing
      }
    }
    return result
  }

  func calculatedFrame(at indexPath: IndexPath) -> CGRect {
    let sectionXPos = sectionStartingXPosition(at: indexPath.section)
    let rectInSection = itemFrameInsideSection(at: indexPath)
    let origin = CGPoint(x: sectionXPos + rectInSection.minX, y: sectionYPos + rectInSection.minY)
    return CGRect(origin: origin, size: rectInSection.size)
  }
  
  private func itemFrameInsideSection(at indexPath: IndexPath) -> CGRect {
    let row = CGFloat(indexPath.item % rowCount)
    let col = CGFloat(indexPath.item / rowCount)
    let origin = CGPoint(x: col * (itemSize.width + columnSpacing),
                         y: row * (itemSize.height + rowSpacing))
    return CGRect(origin: origin, size: itemSize)
  }
  
  private func sectionTitleFrame(at section: Int) -> CGRect {
    let size = CGSize(width: 359.0, height: 29.0)
    let sectionXPos = sectionStartingXPosition(at: section)
    let origin = CGPoint(x: sectionXPos, y: 0.0)
    return CGRect(origin: origin, size: size)
  }
  
  override func configure(attributes: inout UICollectionViewLayoutAttributes, with item: CollectionItem, at indexPath: IndexPath) {
    let frame = calculatedFrame(at: indexPath)
    item.point = frame.origin
    item.size = frame.size
    super.configure(attributes: &attributes, with: item, at: indexPath)
  }
  
  override func prepare() {
    super.prepare()
    if let sectionCount = collectionView?.numberOfSections {
      var newLayoutInfo = layoutInfo!
      var supplimentaryLayoutInfo = [IndexPath: UICollectionViewLayoutAttributes]()
      for section in 0..<sectionCount {
        let indexPath = IndexPath(item: 0, section: section)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: sectionTitleKind, with: indexPath)
        attributes.frame = sectionTitleFrame(at: section)
        supplimentaryLayoutInfo[indexPath] = attributes
      }
      newLayoutInfo[collectionViewSupplimentaryKind] = supplimentaryLayoutInfo
      layoutInfo = newLayoutInfo
    }
  }
}
