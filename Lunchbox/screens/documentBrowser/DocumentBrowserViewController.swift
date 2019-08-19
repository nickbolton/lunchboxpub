//
//  DocumentBrowserViewController.swift
//  Tester
//
//  Created by Nick Bolton on 4/20/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
  
  private let browserDelegate = DocumentBrowserDelegate()
  private var documentController: DocumentViewController?
  
  fileprivate (set) var openDocument: Document?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    delegate = browserDelegate
    
    allowsDocumentCreation = true
    allowsPickingMultipleItems = false
    
    browserUserInterfaceStyle = Design.shared.isDarkMode ? .dark : .light
    view.tintColor = Design.shared.isDarkMode ? .white : .black
    
    // Specify the allowed content types of your application via the Info.plist.
    
    // Do any additional setup after loading the view.
    
    browserDelegate.presentationHandler = { [weak self] url, error in
      guard let `self` = self else { return }
      if let error = error {
        Logger.shared.error("\(error)")
        self.showAlertView(error: error)
        return
      }
      
      if let url = url{
        self.openDocument(url: url)
      }
    }
  }
  
  // MARK: Document Presentation
  
  func present(document: Document) {
    guard documentController == nil else { return }
    let vc = DocumentViewController(document: document)
    vc.delegate = self
    documentController = vc
    present(vc, animated: true, completion: nil)
  }
}

extension DocumentBrowserViewController {
  
  func openDocument(url: URL) {
    
    guard !isDocumentCurrentlyOpen(url: url) else { return }
    
    closeDocumentController {
      let document = Document(fileURL: url)
      document.open { [weak self] openSuccess in
        guard openSuccess else { return }
        self?.openDocument = document
        self?.present(document: document)
      }
    }
  }
  
  //3.
  private func isDocumentCurrentlyOpen(url: URL) -> Bool {
    guard let document = openDocument else { return false }
    return document.fileURL == url && document.documentState != .closed
  }
  
  private func closeDocument()  {
    openDocument?.close()
    openDocument = nil
  }
}

extension DocumentBrowserViewController: DocumentViewControllerDelegate {
  
  func didFinishEditing(_ controller: DocumentViewController) {
    if let document = openDocument {
      document.save(to: document.fileURL, for: .forOverwriting)
    }
    closeDocumentController()
  }
  
  func saveCurrentDocument(_ controller: DocumentViewController) {
    guard let document = openDocument else { return }
    document.save(to: document.fileURL, for: .forOverwriting)
  }
  
  fileprivate func closeDocumentController(completion: (() -> Void)? = nil) {
    
    let compositeClosure = {
      self.closeDocument()
      self.documentController = nil
      completion?()
    }
    
    if let vc = documentController {
      vc.dismiss(animated: true) {
        compositeClosure()
      }
    } else {
      compositeClosure()
    }
  }
}
