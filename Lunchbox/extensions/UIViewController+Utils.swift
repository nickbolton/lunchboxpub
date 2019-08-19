//
//  UIViewController+Utils.swift
//  Canvas
//
//  Created by Nick Bolton on 12/9/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

extension UIViewController {
  
  var canvasVC: CanvasViewController { return documentVC.canvasViewController }
  var stateStore: Store<AppState> { return currentDocument.store }
  var actionDispatcher: ActionDispatcher { return stateStore }
  var documentUndoManager: UndoManager! {
    get { return currentDocument.undoManager }
    set { currentDocument.undoManager = newValue }
  }
  
  var documentVC: DocumentViewController {
    if let vc = self as? DocumentViewController {
      return vc
    }
    guard let result = parent?.documentVC else {
      assert(false, "Failed to find tab manager view controller")
      return parent!.documentVC // just need to return something to avoid compiler error
    }
    return result
  }
  
  var currentDocument: Document {
    return documentVC.document
  }
}
