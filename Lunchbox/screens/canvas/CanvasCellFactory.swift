//
//  CanvasCellFactory.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/22/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

struct CanvasCellFactory {
  
  weak var groupDelegate: GroupDelegate?
  
  private let cellID = "groupCell"
  
  func registerCells(collectionView: UICollectionView) {
    collectionView.register(GroupCell.self, forCellWithReuseIdentifier: cellID)
  }
  
  func cellForItem(at indexPath: IndexPath,
                   canvasState: CanvasState,
                   provider: CollectionDataSourceProvider,
                   collectionView: UICollectionView) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! GroupCell
    if let group = provider.collectionItem(at: indexPath)?.entity as? Group {
      cell.group = group
      cell.canvasState = canvasState
      cell.delegate = groupDelegate
      cell.isHidden = false
      switch canvasState {
      case .groupDragging(let draggingGroup):
        cell.isHidden = group == draggingGroup
      default:
        break
      }
    }
    return cell
  }
  
  func sizeForItem(at indexPath: IndexPath, editingItem: BlockItem?, provider: CollectionDataSourceProvider, collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout) -> CGSize {
    if let group = provider.collectionItem(at: indexPath)?.entity as? Group {
      let height = GroupView.height(for: group, editingItem: editingItem)
      return CGSize(width: group.frame.width, height: height)
    }
    return .zero
  }
}
