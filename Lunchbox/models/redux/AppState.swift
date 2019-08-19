//
//  DataSource.swift
//  Canvas
//
//  Created by Nick Bolton on 12/8/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit
import ReSwift

struct AppState: StateType, Codable {
    
  private (set) var id: String
  
  private (set) var pages: [Page] { didSet { updateSelectedPagePath() } }
  private var selectedPageId: String?
  
  var lastActionPositionDelta = CGVector.zero
  
  var selectedGroup: Group?
  
  var selectedPage: Page? {
    guard let id = selectedPageId else { return nil }
    return (pages.filter { $0.id == id }).first
  }
  
  enum CodingKeys: String, CodingKey {
    case id, pages
  }
  
  init(pages: [Page]) {
    self.id = UUID().uuidString
    self.pages = pages
    updateSelectedPagePath()
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try values.decode(String.self, forKey: .id)
    self.pages = try values.decode([Page].self, forKey: .pages)
    updateSelectedPagePath()
    for idx in 0..<pages.count {
      pages[idx].initializeGroupMap()
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(pages, forKey: .pages)
  }
  
  mutating func select(page: Page) {
    selectedPageId = page.id
  }
  
  mutating func updatePage(page: Page) {
    guard let pageIndex = pages.firstIndex(of: page) else { return }
    pages[pageIndex] = page
  }
  
  private mutating func updateSelectedPagePath() {
    selectedPageId = pages.first?.id
  }

  func page(withId id: String) -> Page? {
    return (pages.filter { $0.id == id }).first
  }
}

extension AppState {
    // MARK: Components    
}
