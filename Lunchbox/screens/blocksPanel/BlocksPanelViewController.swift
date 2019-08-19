//
//  BlocksPanelViewController.swift
//  Lunchbox
//
//  Created by Nick Bolton on 5/12/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

protocol BlocksPanelDelegate {
  
}

class BlocksPanelViewController: NiblessViewController {
  
  private let panelIxResponder: PanelIxResponder
  weak var documentNotifier: DocumentNotifier?
  
  let panelHeight: CGFloat = 457.0
  
  fileprivate lazy var layout: BlocksPanelLayout = {
    let layout = BlocksPanelLayout()
    layout.dataSourceProvider = self
    return layout
  }()
    
  fileprivate lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.contentInset = UIEdgeInsets(top: 0.0, left: 50.0, bottom: 0.0, right: 50.0)
    collectionView.register(BlocksPanelCell.self, forCellWithReuseIdentifier: NSStringFromClass(BlocksPanelCell.self))
    collectionView.register(BlocksSectionSupplementaryView.self, forSupplementaryViewOfKind: layout.sectionTitleKind, withReuseIdentifier: NSStringFromClass(BlocksSectionSupplementaryView.self))
    return collectionView
  }()
  
  init(panelIxResponder: PanelIxResponder) {
    self.panelIxResponder = panelIxResponder
    super.init()
  }
  
  internal var dataSource: [[CollectionItem]]?
  fileprivate let sectionTitleKeys = ["blocks.panel.simple.section.title", "blocks.panel.data.section.title"]

  private (set) lazy var rootView = BlocksPanelRootView(collectionView: collectionView, panelIxResponder: panelIxResponder)
  
  // MARK: Setup
  
  private func setUpCollectionView() {
  }

  // MARK: View Life Cycle
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setUpCollectionView()
    setUpHeaderPanGesture()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadData()
  }
}

extension BlocksPanelViewController {
  // MARK: Header Pan Gesture
  
  fileprivate func setUpHeaderPanGesture() {
    let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleHeaderPan))
    rootView.headerView.addGestureRecognizer(gesture)
  }
  
  @objc private func handleHeaderPan(_ gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      handleHeaderPanBegan(gesture)
    case .changed:
      handleHeaderPanChanged(gesture)
    default:
      handleHeaderPanEnded(gesture)
    }
  }

  private func handleHeaderPanBegan(_ gesture: UIPanGestureRecognizer) {
  }

  private func handleHeaderPanChanged(_ gesture: UIPanGestureRecognizer) {
    guard gesture.isEnabled else { return }
    let dismissTriggerThreshold: CGFloat = 50.0
    let translation = gesture.translation(in: nil)
    let yTranslation = max(translation.y, 0.0)
    view.transform = CGAffineTransform(translationX: 0.0, y: yTranslation)
    if yTranslation >= dismissTriggerThreshold {
      gesture.isEnabled = false
      panelIxResponder.closePanel(rootView)
    }
  }

  private func handleHeaderPanEnded(_ gesture: UIPanGestureRecognizer) {
    guard gesture.isEnabled else { return }
    UIView.animate(withDuration: 0.1) {
      self.view.transform = .identity
    }
  }
}

extension BlocksPanelViewController: CollectionDataSourceProvider {
  
  // MARK: DataSource
  
  fileprivate func reloadData() {
    dataSource = buildDataSource()
    collectionView.reloadData()
  }
  
  private func buildDataSource() -> [[CollectionItem]] {
    let simpleSection = BlockType.simpleTypes.map { CollectionItem().set(entity: $0) }
    let dataSection = BlockType.dataTypes.map { CollectionItem().set(entity: $0) }
    return [simpleSection, dataSection]
  }
}

extension BlocksPanelViewController: UICollectionViewDataSource {
  // MARK: UICollectionViewDataSource Conformance
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return dataSource?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let sectionArray = dataSourceArray(at: section) else { return 0 }
    return sectionArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(BlocksPanelCell.self), for: indexPath) as! BlocksPanelCell
    if let blockItem = collectionItem(at: indexPath)?.entity as? BlockType {
      cell.blockType = blockItem
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let sectionView = collectionView.dequeueReusableSupplementaryView(ofKind: layout.sectionTitleKind, withReuseIdentifier: NSStringFromClass(BlocksSectionSupplementaryView.self), for: indexPath) as! BlocksSectionSupplementaryView
    if indexPath.section >= 0, indexPath.section < sectionTitleKeys.count {
      sectionView.title = sectionTitleKeys[indexPath.section].localized()
    }
    return sectionView
  }
}

extension BlocksPanelViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: false)
    guard let type = collectionItem(at: indexPath)?.entity as? BlockType else { return }
    var group: Group?
    if let selectedGroup = stateStore.state.selectedGroup {
      group = stateStore.state.selectedPage?.group(withId: selectedGroup.id)
    }
    prepareForChange(action: "Add New Block")
    actionDispatcher.dispatch(AddNewBlockAction(blockType: type, group: group, position: nil))
    documentNotifier?.saveDocument()
  }
}

extension BlocksPanelViewController {
  // MARK: Undo
  
  fileprivate func prepareForChange(action: String) {
    let oldState = stateStore.state!
    documentUndoManager.registerUndo(withTarget: self) { vc in
      vc.undo(appState: oldState, action: action)
    }
    documentUndoManager.setActionName(action)
    documentNotifier?.undoManagerUpdated(documentUndoManager)
  }
  
  private func undo(appState: AppState, action: String) {
    let oldState = stateStore.state!
    documentUndoManager.registerUndo(withTarget: self) { vc in
      vc.undo(appState: oldState, action: action)
    }
    documentUndoManager.setActionName(action)
    actionDispatcher.dispatch(ReplaceAppStateAction(appState: appState))
    documentNotifier?.undoManagerUpdated(documentUndoManager)
    documentNotifier?.saveDocument()
  }
}
