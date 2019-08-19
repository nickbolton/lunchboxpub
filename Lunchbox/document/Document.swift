//
//  Document.swift
//  Tester
//
//  Created by Nick Bolton on 4/20/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

let DocumentWindowLastFrameKey = "lastWindowFrame"

extension Notification.Name {
  static let WindowFinishedInitializationNotification = Notification.Name("WindowFinishedInitializationNotification")
}

enum DocumentError: Error {
  case unrecognizedContent
  case corruptDocument
  case archivingFailure
  
  var localizedDescription: String {
    switch self {
      
    case .unrecognizedContent:
      return "document.file.unrecognised.format".localized()
    case .corruptDocument:
      return "document.file.unreadable".localized()
    case .archivingFailure:
      return "document.file.unsaveable".localized()
    }
  }
}

class Document: UIDocument {
  
  static let filenameExtension = "lbox"
  
  var store = Store<AppState>(reducer: Reducers.appStateReducer, state: nil, middleware: [printActionMiddleware])
  
  override func contents(forType typeName: String) throws -> Any {
    do {
      let data = try JSONEncoder().encode(store.state)
      guard !data.isEmpty else { throw DocumentError.archivingFailure }
      return data
    } catch {
      throw DocumentError.archivingFailure
    }
  }
  
  override func load(fromContents contents: Any, ofType typeName: String?) throws {
    guard let data = contents as? Data else { throw DocumentError.unrecognizedContent }
    do {
      let appState = try JSONDecoder().decode(AppState.self, from: data)
      store = Store<AppState>(reducer: Reducers.appStateReducer, state: appState, middleware: [printActionMiddleware])
    } catch {
      throw DocumentError.corruptDocument
    }
  }
}
