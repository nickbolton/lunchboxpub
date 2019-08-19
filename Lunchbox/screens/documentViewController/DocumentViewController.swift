//  
//  DocumentViewController.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/20/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit
import ReSwift
import RxSwift

protocol DocumentViewControllerDelegate: class {
  func saveCurrentDocument(_ controller: DocumentViewController)
  func didFinishEditing(_ controller: DocumentViewController)
}

protocol DocumentNotifier: class {
  func undoManagerUpdated(_ undoManager: UndoManager)
  func saveDocument()
}

class DocumentViewController: NiblessViewController {
  
  let document: Document
  let rootView = DocumentRootView()
  
  init(document: Document) {
    self.document = document
    super.init()
  }
  
  let canvasViewController = CanvasViewController()
  weak var delegate: DocumentViewControllerDelegate?
  fileprivate let interactionGuard = InteractionGuard()
  fileprivate var blocksPanelViewController: BlocksPanelViewController?
  
  private var stateObservable: Observable<AppState>!
  
  private let canvasContainer = UIView()
  
//  override var prefersHomeIndicatorAutoHidden: Bool {
//    return false
//  }
    
  override open var prefersStatusBarHidden: Bool { return true }
  
  // MARK: Setup
  
  private func setupCanvasViewController() {
    canvasViewController.documentNotifier = self
    addChild(canvasViewController)
    let view = canvasViewController.view!
    view.translatesAutoresizingMaskIntoConstraints = false
    canvasContainer.addSubview(view)
    view.expand()
  }
  
  private func setupCanvasContainer() {
    canvasContainer.translatesAutoresizingMaskIntoConstraints = false
    rootView.canvasContainer.addSubview(canvasContainer)
    canvasContainer.expandHeight()
    canvasContainer.expandWidth()
  }
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupCanvasContainer()
    setupCanvasViewController()
    rootView.sidebarButton.addTarget(self, action: #selector(sidebarTapped), for: .touchUpInside)
    rootView.undoButton.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
    rootView.redoButton.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
    rootView.addBlockButton.addTarget(self, action: #selector(addBlockTapped), for: .touchUpInside)
    rootView.addLinkButton.addTarget(self, action: #selector(addLinkTapped), for: .touchUpInside)
    rootView.markupButton.addTarget(self, action: #selector(markupTapped), for: .touchUpInside)
    rootView.zoomButton.addTarget(self, action: #selector(zoomTapped), for: .touchUpInside)
    rootView.zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)
    rootView.zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)
    observeApplicationWillTerminate()
    observeApplicationDidEnterBackground()
    rootView.zoomLevel = 1.0
    updateUndoButtonState()
    stateStore.subscribe(self)
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    rootView.setNeedsUpdateConstraints()
  }
  
  // MARK: Actions
  
  @objc private func sidebarTapped() {
    interactionGuard.perform { delegate?.didFinishEditing(self) }
  }
  
  @objc private func undoTapped() {
    interactionGuard.perform { canvasViewController.undo() }
  }
  
  @objc private func redoTapped() {
    interactionGuard.perform { canvasViewController.redo() }
  }
  
  @objc private func addBlockTapped() {
    interactionGuard.perform { presentBlocksPanel() }
  }

  @objc private func addLinkTapped() {
    interactionGuard.perform { deleteSelection() }
  }
  
  @objc private func markupTapped() {
    interactionGuard.perform { deleteAllGroups() }
  }
  
  @objc private func zoomTapped() {
    interactionGuard.perform { canvasViewController.resetZoom() }
  }
  
  @objc private func zoomOutTapped() {
    interactionGuard.perform { canvasViewController.zoomOut() }
  }
  
  @objc private func zoomInTapped() {
    interactionGuard.perform { canvasViewController.zoomIn() }
  }
  
  private func deleteSelection() {
    guard let group = stateStore.state.selectedGroup else { return }
    prepareForChange(action: "Delete Group")
    actionDispatcher.dispatch(DeleteGroupAction(group: group))
  }
  
  private func deleteAllGroups() {
    prepareForChange(action: "Delete All Groups")
    actionDispatcher.dispatch(DeleteAllGroupsAction())
  }
  
  // MARK: Notifications
  
  override func applicationWillTerminate(noti: NSNotification) {
    super.applicationWillTerminate(noti: noti)
    delegate?.saveCurrentDocument(self)
  }
  
  override func applicationDidEnterBackground(noti: NSNotification) {
    super.applicationDidEnterBackground(noti: noti)
    delegate?.saveCurrentDocument(self)
  }
  
  // MARK: Helpers
  
  private func updateUndoButtonState() {
    rootView.undoButton.isEnabled = documentUndoManager.canUndo
    rootView.redoButton.isEnabled = documentUndoManager.canRedo
  }
  
  // MARK: CanvasViewControllerDelegate Conformance
  
  func canvasDidFinishEditing(_ controller: CanvasViewController) {
    delegate?.didFinishEditing(self)
  }
}

extension DocumentViewController: StoreSubscriber {
  typealias StoreSubscriberStateType = AppState
  
  func newState(state: StoreSubscriberStateType) {
    rootView.addressTitle = state.selectedPage?.title ?? ""
  }
}

extension DocumentViewController: DocumentNotifier {
  func undoManagerUpdated(_ undoManager: UndoManager) {
    delegate?.saveCurrentDocument(self)
    updateUndoButtonState()
  }
  
  func saveDocument() {
    delegate?.saveCurrentDocument(self)
  }
}

extension DocumentViewController: PanelIxResponder {
  // MARK: Blocks Panel
  
  func presentBlocksPanel() {
    let vc = BlocksPanelViewController(panelIxResponder: self)
    vc.documentNotifier = self
    let view = vc.view!
    blocksPanelViewController = vc
    addChild(vc)
    rootView.addSubview(view)
    view.expandWidth()
    view.alignBottom()
    view.layout(height: vc.panelHeight)
    view.transform = CGAffineTransform(translationX: 0.0, y: vc.panelHeight)
    UIView.animate(withDuration: 0.3) {
      view.transform = .identity
    }
  }
  
  private func dismissBlocksPanel() {
    guard let vc = blocksPanelViewController else { return }
    UIView.animate(withDuration: 0.3, animations: {
      vc.view.transform = CGAffineTransform(translationX: 0.0, y: vc.panelHeight)
    }) { [weak self] _ in
      self?.cleanUpBlocksPanel()
    }
  }
  
  private func cleanUpBlocksPanel() {
    guard let vc = blocksPanelViewController else { return }
    vc.willMove(toParent: nil)
    vc.view.removeFromSuperview()
    vc.didMove(toParent: nil)
    blocksPanelViewController = nil
  }
  
  func closePanel(_ panelView: PanelView) {
    guard let vc = blocksPanelViewController else { return }
    guard panelView === vc.view else { return }
    dismissBlocksPanel()
  }
}

extension DocumentViewController {
  // MARK: Undo
  
  fileprivate func prepareForChange(action: String) {
    let oldState = stateStore.state!
    documentUndoManager.registerUndo(withTarget: self) { vc in
      vc.undo(appState: oldState, action: action)
    }
    documentUndoManager.setActionName(action)
    undoManagerUpdated(documentUndoManager)
  }
  
  private func undo(appState: AppState, action: String) {
    let oldState = stateStore.state!
    documentUndoManager.registerUndo(withTarget: self) { vc in
      vc.undo(appState: oldState, action: action)
    }
    documentUndoManager.setActionName(action)
    actionDispatcher.dispatch(ReplaceAppStateAction(appState: appState))
    undoManagerUpdated(documentUndoManager)
    saveDocument()
  }
}
