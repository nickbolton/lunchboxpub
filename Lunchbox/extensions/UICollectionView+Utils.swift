//
//  UICollectionView+Utils.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/7/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit

extension UICollectionView {
  func reloadItems(at indexPaths: [IndexPath], animated: Bool) {
    if !animated {
      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    }
    reloadItems(at: indexPaths)
    
    if !animated {
      CATransaction.commit()
    }
  }
}
