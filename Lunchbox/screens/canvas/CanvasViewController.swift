//  
//  CanvasViewController.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/21/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit
import ReSwift

enum CanvasState {
  case none
  case groupSelected(Group)
  case blockSelected(BlockItem)
  case blockTextEditing(BlockItem)
  case groupDraggingBegan(Group)
  case groupDragging(Group)
  case groupResizing(Group, GroupResizePosition)
  case blockDraggingBegan(BlockItem)
  case blockDragging(BlockItem)
}

struct DraggingState {
  
  var sourceView: UIView?
  var initialFrame = CGRect.zero
  var initialPoint = CGPoint.zero
  var frameOffset = CGPoint.zero
  var originalPosition: BlockPosition?
  var targetPosition: BlockPosition?
  var lastTargetPlacement: TargetBlockPlacement?
  var originalState: AppState?
  var promotedBlock: BlockItem?
  var previousCanvasState = CanvasState.none
  var didChangeFrame = false
  var didChangePosition: Bool { return targetPosition != originalPosition || didChangeFrame }
}

struct PinchStartState {
  let contentOffset: CGPoint
  let scale: CGFloat
  let windowLocation: CGPoint
}

enum DraggingDirection {
  case up
  case down
}

struct TargetBlockPlacement: Equatable {
  let blockItem: BlockItem
  let after: Bool
  
  static func == (lhs: TargetBlockPlacement, rhs: TargetBlockPlacement) -> Bool {
    return lhs.blockItem == rhs.blockItem
      && lhs.after == rhs.after
  }
}

class CanvasViewController: NiblessViewController, CanvasDelegate {
  
  let rootView = CanvasRootView()
  var canvasView: CanvasView { return rootView.canvasView }
  private let interactionGuard = InteractionGuard()
  
  weak var documentNotifier: DocumentNotifier?
  
  private var uneditedBlock: Block?
  
  fileprivate var draggingState = DraggingState()
  fileprivate var pinchStartState: PinchStartState?
  fileprivate var editingGroup: Group?
  
  fileprivate var page: Page!
  
  private var highlightedGroup: Group?
  private var highlightedBlockItem: BlockItem?
  
  fileprivate var ignoreStateChange = false
  
  private let groupSizer = GroupSizer()
  
  fileprivate var panGesture: UIPanGestureRecognizer!
  fileprivate var pinchGesture: UIPinchGestureRecognizer!
  
  private var changesExist: Bool {
    guard let editingItem = editingBlockItem else { return false }
    guard let uneditedBlock = uneditedBlock else { return false }
    return !editingItem.block.isContentEqual(to: uneditedBlock)
  }
  
  // MARK: CanvasDelegate Conformance
  
  internal var canvasState = CanvasState.none
  internal var editingBlockItem: BlockItem?
  internal func isSelected(group: Group) -> Bool { return selectedGroup == group }

  // MARK: Setup
  
  private func setUpLongPressGesture() {
    let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
    gesture.minimumPressDuration = 0.0
    gesture.delegate = self
    view.addGestureRecognizer(gesture)
  }
  
  private func setUpPanGesture() {
    let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    gesture.delegate = self
    canvasView.addGestureRecognizer(gesture)
    panGesture = gesture
  }
  
  private func setUpPinchGesture() {
    let gesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
    gesture.delegate = self
    canvasView.addGestureRecognizer(gesture)
    pinchGesture = gesture
  }
  
  // MARK: View Lifecycle
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rootView.canvasView.canvasDelegate = self
    setUpLongPressGesture()
    setUpPanGesture()
    setUpPinchGesture()
    stateStore.subscribe(self)
  }
  
  // MARK: DataSource
  
  fileprivate func reloadData() {
    canvasView.groups = stateStore.state.selectedPage?.groups ?? []
  }
  
  // MARK: Gestures
  
  private var isPanning: Bool {
    switch panGesture.state {
    case .began, .changed:
      return true
    default:
      return false
    }
  }
  
  @objc private func handleLongPress(_ gesture: UITapGestureRecognizer) {
    guard !isPanning else {
      clearHighlightState()
      gesture.isEnabled = false
      gesture.isEnabled = true
      return
    }
    let location = gesture.location(in: canvasView)
    if gesture.state == .began {
      switch canvasState {
      case .none:
        if let group = canvasView.group(at: location) {
          highlight(group: group)
        } else {
          clearHighlightState()
        }
      case .groupSelected(let selectedGroup):
        if let group = canvasView.group(at: location) {
          if selectedGroup == group {
            if let blockItem = canvasView.block(at: location) {
              highlight(blockItem: blockItem)
            }
          } else {
            highlight(group: group)
          }
        }
      case .blockSelected(let selectedItem):
        if let group = canvasView.group(at: location) {
          if group == selectedItem.group {
            if let blockItem = canvasView.block(at: location) {
              highlight(blockItem: blockItem)
            }
          } else {
            highlight(group: group)
          }
        }
      default:
        clearHighlightState()
      }
      return
    }
    clearHighlightState()
    guard gesture.state == .ended else { return }
    interactionGuard.perform {
      let sourceTextView = canvasView.blockTextView(at: location)
      if let blockItem = canvasView.block(at: location) {
        didTapBlock(group: blockItem.group, block: blockItem.block, sourceTextView: sourceTextView)
      } else if let group = canvasView.group(at: location) {
        didTapGroup(group: group)
      } else {
        switch canvasState {
        case .blockTextEditing:
          endTextEditing()
        default:
          clearState()
        }
      }
    }
  }
  
  // MARK: Helpers
  
  func undo() {
    documentUndoManager.undo()
    documentNotifier?.undoManagerUpdated(documentUndoManager)
  }
  
  func redo() {
    documentUndoManager.redo()
    documentNotifier?.undoManagerUpdated(documentUndoManager)
  }
      
  private func scrollToHomePosition(animated: Bool) {
    let co = CGPoint(x: -canvasView.contentMargin, y: -canvasView.contentMargin)
    canvasView.setContentOffset(co, animated: animated)
  }
  
  private func scrollItemToEditingPosition(for group: Group) {
    let itemRect = group.frame
    let dx = (canvasView.bounds.width - itemRect.width) / 2.0 + canvasView.contentOffset.x - itemRect.minX
    let dy = canvasView.contentOffset.y + canvasView.contentInset.top - itemRect.minY
    UIView.animate(withDuration: 0.3) {
      self.canvasView.transform = CGAffineTransform(translationX: dx, y: dy)
    }
  }
  
  private func editBlockLabel(group: Group, block: Block, sourceTextView: BlockGroupedTextView) {
    uneditedBlock = block
    let blockItem = BlockItem(group: group, block: block)
    editingBlockItem = blockItem
    editingGroup = blockItem.group
    canvasView.editingTextView.delegate = self
    canvasView.startTextEditing(item: blockItem, sourceTextView: sourceTextView)
    reloadEditingGroup()
    scrollItemToEditingPosition(for: blockItem.group)
  }
  
  private func switchEditingBlock(group: Group, block: Block, sourceTextView: BlockGroupedTextView) {
    saveChangesIfNecessary()
    endEditingItem()
    editBlockLabel(group: group, block: block, sourceTextView: sourceTextView)
  }
  
  private func actionTitle(for block: Block, group: Group) -> String {
    if group.isTitleBlock(block) {
      return "canvas.undo.title.change".localized()
    }
    return ""
  }
  
  private func saveChangesIfNecessary() {
    if changesExist {
      if var blockItem = editingBlockItem {
        prepareForChange(action: actionTitle(for: blockItem.block, group: blockItem.group))
        if blockItem.block.defaultText == blockItem.block.text {
          blockItem.block.text = ""
        }
        actionDispatcher.dispatch(UpdateBlockTextAction(blockItem: blockItem))
        editingBlockItem = nil
        canvasView.reload(group: blockItem.group)
        documentNotifier?.saveDocument()
      }
    }
  }
  
  private func endEditingItem() {
    let blockItem = editingBlockItem
    editingBlockItem = nil
    uneditedBlock = nil
    editingGroup = nil
    if let item = blockItem {
      canvasState = .blockSelected(item)
    } else {
      clearState()
    }
  }
  
  private func endTextEditing(onComplete: DefaultHandler? = nil) {
    canvasView.editingTextView.delegate = nil
    saveChangesIfNecessary()
    endEditingItem()
    canvasView.endTextEditing()
    UIView.animate(withDuration: 0.3, animations: {
      self.canvasView.transform = .identity
    }) { _ in
      onComplete?()
    }
  }
  
  private func indexPath(for group: Group) -> IndexPath? {
    guard let page = stateStore.state.selectedPage else { return nil }
    guard let item = page.groups.firstIndex(of: group) else { return nil }
    return IndexPath(item: item, section: 0)
  }
  
  private func reloadEditingGroupView() {
    guard let group = editingGroup else { return }
    canvasView.reload(group: group)
  }
  
  fileprivate func reloadTextEditor() {
    guard let group = editingGroup else { return }
    guard let blockItem = editingBlockItem else { return }
    guard let item = page.groups.firstIndex(of: blockItem.group) else { return }
    guard let groupView = canvasView.groupView(for: group) else { return }
    let blocks = page.groups[item].blocks
    guard let blockIndex = blocks.firstIndex(of: blockItem.block) else { return }
    guard let textView = groupView.blockTextView(atIndex: blockIndex) else { return }
    switch blockItem.block.type {
    case .label, .body, .labelBody:
      canvasView.updateTextEditing(item: blockItem,
                                   sourceTextView: textView)
    default:
      break
    }
  }
  
  private func reloadEditingGroup() {
    reloadEditingGroupView()
    guard let group = editingGroup else { return }
    guard let page = stateStore.state.selectedPage else { return }
    guard let blockItem = editingBlockItem else { return }
    guard let item = page.groups.firstIndex(of: blockItem.group) else { return }
    let blocks = page.groups[item].blocks
    guard let blockIndex = blocks.firstIndex(of: blockItem.block) else { return }
    
    guard let groupView = canvasView.groupView(for: group) else {
      endTextEditing()
      return
    }
    
    // this forces the text view to layout and have a proper frame
    groupView.applyTheme()

    guard let textView = groupView.blockTextView(atIndex: blockIndex) else {
      endTextEditing()
      return
    }
    
    switch blockItem.block.type {
    case .label, .body, .labelBody:
      canvasView.updateTextEditing(item: blockItem,
                                   sourceTextView: textView)
    default:
      break
    }
  }
  
  private func reloadDraggingSourceIndexPath() {
    guard let group = currentDraggingBlock?.group ?? currentDraggingGroup else { return }
    if let draggingBlock = currentDraggingBlock {
      guard draggingBlock != draggingState.promotedBlock else { return }
    }
    canvasView.reload(group: group)
  }
}

extension CanvasViewController {
  // MARK: Highlighing
  
  fileprivate func highlight(blockItem: BlockItem) {
    clearHighlightState()
    highlightedBlockItem = blockItem
    canvasView.groupView(for: blockItem.group)?.setBlockHighlighted(blockItem: blockItem, highlighted: true)
  }
  
  fileprivate func highlight(group: Group) {
    clearHighlightState()
    highlightedGroup = group
    canvasView.groupView(for: group)?.isHighlighted = true
  }
  
  fileprivate func clearHighlightState() {
    if let group = highlightedGroup {
      canvasView.groupView(for: group)?.isHighlighted = false
    }
    if let blockItem = highlightedBlockItem {
      canvasView.groupView(for: blockItem.group)?.setBlockHighlighted(blockItem: blockItem, highlighted: false)
    }
    highlightedGroup = nil
    highlightedBlockItem = nil
  }
}

extension CanvasViewController {
  // MARK: Editing
  
  fileprivate func delete(blockItem: BlockItem) {
    prepareForChange(action: "Delete Block")
    actionDispatcher.dispatch(DeleteBlockAction(blockItem: blockItem))
  }
    
  fileprivate func delete(group: Group) {
    prepareForChange(action: "Delete Group")
    actionDispatcher.dispatch(DeleteGroupAction(group: group))
  }
}

extension CanvasViewController {
  // MARK: Undo
  
  fileprivate func prepareForChange(action: String) {
    prepareForChange(action: action, oldState: stateStore.state)
  }
  
  fileprivate func prepareForChange(action: String, oldState: AppState) {
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
    //    reloadData()
    documentNotifier?.undoManagerUpdated(documentUndoManager)
    documentNotifier?.saveDocument()
  }
}

extension CanvasViewController {
  
  fileprivate func setGroupSelectedState(group: Group) {
    canvasState = .groupSelected(group)
    stateStore.state.selectedGroup = group
  }
  
  fileprivate func clearState() {
    canvasState = .none
    stateStore.state.selectedGroup = nil
  }
  
  fileprivate func didTapGroup(group: Group) {
    switch canvasState {
    case .none:
      setGroupSelectedState(group: group)
      canvasView.reload(group: group)
    case .groupSelected(let selectedGroup):
      if group != selectedGroup {
        let previousGroup = selectedGroup
        setGroupSelectedState(group: group)
        canvasView.reload(groups: [group, previousGroup])
      }
    case .blockSelected(let selectedBlock):
      if selectedBlock.group == group {
        setGroupSelectedState(group: group)
        canvasView.reload(group: group)
      } else {
        let previousGroup = selectedBlock.group
        setGroupSelectedState(group: group)
        canvasView.reload(groups: [group, previousGroup])
      }
    case .blockTextEditing(let editingBlock):
      endTextEditing { [weak self] in
        if editingBlock.group == group {
          self?.setGroupSelectedState(group: group)
          self?.canvasView.reload(group: group)
        } else {
          let previousGroup = editingBlock.group
          self?.setGroupSelectedState(group: group)
          self?.canvasView.reload(groups: [group, previousGroup])
        }
      }
    default:
      break
    }
  }
  
  fileprivate func didTapBlock(group: Group, block: Block, sourceTextView: BlockGroupedTextView?) {
    switch canvasState {
    case .none:
      setGroupSelectedState(group: group)
      canvasView.reload(group: group)
    case .groupSelected(let selectedGroup):
      if selectedGroup == group {
        let blockItem = BlockItem(group: group, block: block)
        canvasState = .blockSelected(blockItem)
        canvasView.reload(group: group)
      } else {
        let previousGroup = selectedGroup
        setGroupSelectedState(group: group)
        canvasView.reload(groups: [group, previousGroup])
      }
    case .blockSelected(let selectedBlock):
      if selectedBlock.block == block {
        if let textView = sourceTextView {
          canvasState = .blockTextEditing(selectedBlock)
          editBlockLabel(group: group, block: block, sourceTextView: textView)
        }
      } else if selectedBlock.group == group {
        let blockItem = BlockItem(group: group, block: block)
        canvasState = .blockSelected(blockItem)
        canvasView.reload(group: group)
      } else {
        let previousGroup = selectedBlock.group
        setGroupSelectedState(group: group)
        canvasView.reload(groups: [group, previousGroup])
      }
    case .blockTextEditing(let editingBlock):
      if editingBlock.block != block {
        endTextEditing { [weak self] in
          if editingBlock.group == group {
            let blockItem = BlockItem(group: group, block: block)
            self?.canvasState = .blockSelected(blockItem)
            self?.canvasView.reload(group: group)
          } else {
            let previousGroup = editingBlock.group
            self?.setGroupSelectedState(group: group)
            self?.canvasView.reload(groups: [group, previousGroup])
          }
        }
      }
    default:
      break
    }
  }
}

extension CanvasViewController: StoreSubscriber {
  // MARK: StoreSubscriber Conformance
  typealias StoreSubscriberStateType = AppState
  
  func newState(state: StoreSubscriberStateType) {
    guard let updatedPage = state.selectedPage else { return }
    guard !ignoreStateChange else { return }
    page = updatedPage
    if let group = state.selectedGroup {
      ignoreStateChange = true
      switch canvasState {
      case .groupSelected, .groupDraggingBegan, .groupDragging, .groupResizing:
        canvasState = updatedCanvasState(group: group)
        stateStore.state.selectedGroup = group
      case .blockSelected, .blockTextEditing, .blockDraggingBegan, .blockDragging:
        break
      default:
        setGroupSelectedState(group: group)
      }
      ignoreStateChange = false
    }
    switch canvasState {
    case .blockSelected, .blockDraggingBegan, .blockDragging, .blockTextEditing:
      reloadData()
    case .groupDragging:
      reloadData()
    case .groupSelected(let group), .groupDraggingBegan(let group), .groupResizing(let group, _):
      if page.group(withId: group.id) != nil {
        reloadData()
      } else {
        ignoreStateChange = true
        clearState()
        ignoreStateChange = false
        reloadData()
      }
    default:
      reloadData()
    }
  }
}

extension CanvasViewController: UITextViewDelegate {
  // MARK: UITextViewDelegate Conformance
  
  func textViewDidChange(_ textView: UITextView) {
    guard let blockItem = editingBlockItem else { return }
    switch blockItem.block.type {
    case .label, .body, .labelBody:
      updateEditingBlock(text: textView.text)
      reloadEditingGroup()
    default:
      break
    }
  }
  
  private func updateEditingBlock(text: String) {
    guard let page = stateStore.state.selectedPage else { return }
    guard var blockItem = editingBlockItem else { return }
    guard var group = page.group(withId: blockItem.group.id) else { return }
    blockItem.block.text = text
    var frame = group.frame
    frame.size.height = groupSizer.height(for: group, editingItem: blockItem)
    frame = frame.halfPointAligned
    if frame != group.frame {
      group.update(frame: frame)
      actionDispatcher.dispatch(UpdateGroupAction(group: group, reposition: true))
    }
    blockItem = BlockItem(group: group, block: blockItem.block)
    editingBlockItem = blockItem
    canvasState = .blockTextEditing(blockItem)
  }
}

extension CanvasViewController: UIGestureRecognizerDelegate {
  // UIGestureRecognizerDelegate Conformance
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

extension CanvasViewController {
  // MARK: Dragging
  
  @objc fileprivate func handlePan(_ gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .began:
      handlePanBegan(gesture)
    case .changed:
      handlePanChanged(gesture)
    default:
      handlePanEnded(gesture)
    }
  }
  
  private func handlePanBegan(_ gesture: UIPanGestureRecognizer) {
    draggingState = DraggingState()
    draggingState.originalState = stateStore.state
    draggingState.previousCanvasState = canvasState
    draggingState.initialPoint = gesture.location(in: canvasView)
    clearHighlightState()
    switch canvasState {
    case .blockSelected(let blockItem):
      canvasState = .blockDraggingBegan(blockItem)
    case .groupSelected(let group):
      draggingState.initialFrame = group.frame
      if let groupView = canvasView.groupView(for: group),
        let position = groupView.handlePosition(at: gesture.location(in: groupView)) {
        canvasState = .groupResizing(group, position)
      } else {
        canvasState = .groupDraggingBegan(group)
      }
    default:
      break
    }
  }

  private func handlePanChanged(_ gesture: UIPanGestureRecognizer) {
    let location = gesture.location(in: canvasView)
    let velocity = gesture.velocity(in: canvasView)
    let direction: DraggingDirection = velocity.y >= 0 ? .down : .up
    switch canvasState {
      
    case .blockDraggingBegan(let blockItem):
      captureDraggingSourceView(blockItem: blockItem, at: location)
      canvasState = .blockDragging(blockItem)
      reloadDraggingSourceIndexPath()
      updateDraggingView(at: location)
      initializeTargetBlockPosition()

    case .blockDragging:
      updateDraggingView(at: location)
      updateBlockPosition(direction: direction)
      
    case .groupDraggingBegan(let group):
      captureDraggingSourceView(group: group, at: location)
      canvasState = .groupDragging(group)
      reloadDraggingSourceIndexPath()
      updateDraggingView(at: location)
      
    case .groupDragging:
      updateDraggingView(at: location)
      updateGroupPosition(direction: direction)
      
    case .groupResizing(_, let pos):
      resizeGroup(position: pos, at: location, reposition: false)
    default:
      break
    }
  }
  
  private func updatedCanvasState(group: Group) -> CanvasState {
    switch canvasState {
    case .groupSelected:
      return .groupSelected(group)
    case .groupDraggingBegan:
      return .groupDraggingBegan(group)
    case .groupDragging:
      return .groupDragging(group)
    case .groupResizing(_, let pos):
      return .groupResizing(group, pos)
    default:
      return canvasState
    }
  }
  
  private func updatedCanvasState(blockItem: BlockItem) -> CanvasState {
    switch canvasState {
    case .blockSelected:
      return .blockSelected(blockItem)
    case .blockTextEditing:
      return .blockTextEditing(blockItem)
    case .blockDraggingBegan:
      return .blockDraggingBegan(blockItem)
    case .blockDragging:
      return .blockDragging(blockItem)
    default:
      return canvasState
    }
  }
  
  private func updatedCanvasStateWithCurrentItem(_ canvasState: CanvasState) -> CanvasState {
    switch canvasState {
    case .groupSelected:
      guard let currentGroup = currentDraggingGroup else { return canvasState }
      return .groupSelected(currentGroup)
    case .groupDraggingBegan:
      guard let currentGroup = currentDraggingGroup else { return canvasState }
      return .groupDraggingBegan(currentGroup)
    case .groupDragging:
      guard let currentGroup = currentDraggingGroup else { return canvasState }
      return .groupDragging(currentGroup)
    case .groupResizing(_, let pos):
      guard let currentGroup = currentDraggingGroup else { return canvasState }
      return .groupResizing(currentGroup, pos)
    case .blockSelected:
      guard let currentBlock = currentDraggingBlock else { return canvasState }
      return .blockSelected(currentBlock)
    case .blockTextEditing:
      guard let currentBlock = currentDraggingBlock else { return canvasState }
      return .blockTextEditing(currentBlock)
    case .blockDraggingBegan:
      guard let currentBlock = currentDraggingBlock else { return canvasState }
      return .blockDraggingBegan(currentBlock)
    case .blockDragging:
      guard let currentBlock = currentDraggingBlock else { return canvasState }
      return .blockDragging(currentBlock)
    default:
      return canvasState
    }
  }

  private func handlePanEnded(_ gesture: UIPanGestureRecognizer) {
    switch canvasState {
    case .blockDragging(let blockItem):
      draggingState.sourceView?.removeFromSuperview()
      if draggingState.targetPosition == nil {
        promoteBlockToGroup(blockItem: blockItem)
        let page = stateStore.state.selectedPage
        if let group = page?.lastAddedBlock?.group {
          setGroupSelectedState(group: group)
        } else {
          clearState()
        }
      } else {
        canvasState = .blockSelected(blockItem)
      }
      registerDraggingUndoActionIfNecessary()
      saveDraggingOperationIfNecessary()
    case .groupDragging:
      updateGroupPosition()
      draggingState.sourceView?.removeFromSuperview()
      if let group = draggingState.lastTargetPlacement?.blockItem.group {
        if let blockItem = stateStore.state.selectedPage?.lastAddedBlock {
          canvasState = .blockSelected(blockItem)
        } else {
          setGroupSelectedState(group: group)
        }
      } else {
        canvasState = updatedCanvasStateWithCurrentItem(draggingState.previousCanvasState)
      }
      reloadDraggingSourceIndexPath()
      registerDraggingUndoActionIfNecessary()
      saveDraggingOperationIfNecessary()
    case .groupResizing:
      if let draggingGroup = currentDraggingGroup {
        actionDispatcher.dispatch(UpdateGroupAction(group: draggingGroup, reposition: true))
      }
      registerDraggingUndoActionIfNecessary()
      saveDraggingOperationIfNecessary()
      canvasState = updatedCanvasStateWithCurrentItem(draggingState.previousCanvasState)
    default:
      canvasState = updatedCanvasStateWithCurrentItem(draggingState.previousCanvasState)
      break
    }
    draggingState = DraggingState()
  }
  
  private func saveDraggingOperationIfNecessary() {
    guard draggingState.didChangePosition else { return }
    documentNotifier?.saveDocument()
  }
  
  private func registerDraggingUndoActionIfNecessary() {
    guard draggingState.didChangePosition else { return }
    guard let originalState = draggingState.originalState else { return }
    prepareForChange(action: "Moving Block", oldState: originalState)
  }
    
  private func captureDraggingSourceView(blockItem: BlockItem, at point: CGPoint) {
    draggingState.sourceView = nil
    draggingState.initialFrame = .zero
    draggingState.frameOffset = .zero
    draggingState.originalPosition = nil
    guard let page = stateStore.state.selectedPage else { return }
    guard let groupView = canvasView.groupView(for: blockItem.group) else { return }
    guard let blockView = groupView.blockView(for: blockItem) else { return }
    if let view = blockView.snapshotView(afterScreenUpdates: false) {
      draggingState.originalPosition = page.blockPosition(for: blockItem)
      canvasView.addSubview(view)
      draggingState.sourceView = view
      draggingState.initialFrame = canvasView.convert(blockView.bounds, from: blockView)
      draggingState.frameOffset = CGPoint(x: draggingState.initialFrame.minX - point.x,
                                    y: draggingState.initialFrame.minY - point.y)
    }
  }
  
  private func captureDraggingSourceView(group: Group, at point: CGPoint) {
    draggingState.sourceView = nil
    draggingState.initialFrame = .zero
    draggingState.frameOffset = .zero
    guard let groupView = canvasView.groupView(for: group) else { return }

    let view = GroupView(group: group)
    view.isDragging = true
    canvasView.addSubview(view)
    draggingState.sourceView = view
    view.update(group: group, canvasState: canvasState, scale: canvasView.scale)
    view.frame = canvasView.convert(groupView.bounds, from: groupView)
    draggingState.initialFrame = view.frame
    draggingState.frameOffset = CGPoint(x: draggingState.initialFrame.minX - point.x,
                                        y: draggingState.initialFrame.minY - point.y)
  }
  
  private var currentDraggingBlock: BlockItem? {
    if let blockItem = draggingState.promotedBlock {
      return blockItem
    }
    switch canvasState {
    case .blockDragging(let blockItem):
      return fetchGroup(withId: blockItem.group.id)?.blockItem(withId: blockItem.block.id)
    default:
      return nil
    }
  }
  
  private func fetchGroup(withId id: String) -> Group? {
    guard let page = stateStore.state.selectedPage else { return nil }
    return page.group(withId: id)
  }
  
  private var selectedGroup: Group? {
    guard let group = stateStore.state.selectedGroup else { return nil }
    return fetchGroup(withId: group.id)
  }
  
  private var currentDraggingGroup: Group? {
    switch canvasState {
    case .groupDragging(let group):
      return fetchGroup(withId: group.id) ?? group
    case .groupResizing(let group, _):
      return fetchGroup(withId: group.id)
    default:
      return nil
    }
  }
  
  private func promoteBlockToGroup(blockItem: BlockItem) {
    guard let sourceView = draggingState.sourceView else { return }
    let frame = sourceView.frame.scale(by: canvasView.scale.inverse)
    actionDispatcher.dispatch(PromoteBlockToGroupAction(block: blockItem.block, frame: frame))
  }
  
  private func targetBlockPlacement(at point: CGPoint, direction: DraggingDirection) -> TargetBlockPlacement? {
    guard let blockView = canvasView.closestBlockView(at: point) else { return nil }
    guard let blockItem = blockView.blockItem else { return nil }
    let blockFrame = canvasView.convert(blockView.bounds, from: blockView)
    if direction == .down {
      if point.y >= blockFrame.midY {
        return TargetBlockPlacement(blockItem: blockItem, after: true)
      }
      return TargetBlockPlacement(blockItem: blockItem, after: false)
    }
    // direction up
    if point.y < blockFrame.midY {
      return TargetBlockPlacement(blockItem: blockItem, after: false)
    }
    return TargetBlockPlacement(blockItem: blockItem, after: true)
  }
  
  private func updateBlockPosition(direction: DraggingDirection) {
    guard let sourceView = draggingState.sourceView else { return }
    guard let draggingBlock = currentDraggingBlock else { return }
    let sourceCenter = sourceView.center
    guard let targetPlacement = targetBlockPlacement(at: sourceCenter, direction: direction) else {
      draggingState.lastTargetPlacement = nil
      draggingState.targetPosition = nil
      draggingState.promotedBlock = draggingBlock
      delete(blockItem: draggingBlock)
      return
    }
    guard targetPlacement.blockItem != draggingBlock else { return }
    guard targetPlacement != draggingState.lastTargetPlacement else { return }
    
    draggingState.lastTargetPlacement = targetPlacement
    
    if targetPlacement.after {
      actionDispatcher.dispatch(MoveBlockAfterAction(blockItem: draggingBlock, targetItem: targetPlacement.blockItem))
    } else {
      actionDispatcher.dispatch(MoveBlockBeforeAction(blockItem: draggingBlock, targetItem: targetPlacement.blockItem))
    }
    updateTargetBlockPosition()
  }
  
  private func updateGroupPosition(direction: DraggingDirection) {
    guard let sourceView = draggingState.sourceView else { return }
    guard var draggingGroup = currentDraggingGroup else { return }
    let sourceCenter = sourceView.center
    guard let targetPlacement = targetBlockPlacement(at: sourceCenter, direction: direction) else {
      actionDispatcher.dispatch(DetachGroupAction(group: draggingGroup, from: draggingState.lastTargetPlacement?.blockItem.group))
      draggingState.lastTargetPlacement = nil
      draggingGroup.update(frame: sourceView.frame)
      return
    }
    guard targetPlacement != draggingState.lastTargetPlacement else { return }
    
    draggingState.lastTargetPlacement = targetPlacement
    
    if targetPlacement.after {
      actionDispatcher.dispatch(MoveGroupAfterAction(group: draggingGroup, targetItem: targetPlacement.blockItem))
    } else {
      actionDispatcher.dispatch(MoveGroupBeforeAction(group: draggingGroup, targetItem: targetPlacement.blockItem))
    }
  }
  
  private func initializeTargetBlockPosition() {
    guard let page = stateStore.state.selectedPage else { return }
    guard let draggingBlock = currentDraggingBlock else { return }
    draggingState.targetPosition = page.blockPosition(for: draggingBlock)
  }
  
  private func updateTargetBlockPosition() {
    guard let page = stateStore.state.selectedPage else { return }
    guard let updatedBlock = page.lastAddedBlock else { return }
    canvasState = .blockDragging(updatedBlock)
    draggingState.targetPosition = page.lastAddedPosition ?? page.blockPosition(for: updatedBlock)
  }
  
  private func updateDraggingView(at point: CGPoint) {
    let origin = point.offset(dx: draggingState.frameOffset.x, y: draggingState.frameOffset.y)
    let frame = CGRect(origin: origin, size: draggingState.initialFrame.size)
    draggingState.sourceView?.frame = frame
  }
  
  private func updateGroupPosition() {
    guard var draggingGroup = currentDraggingGroup else { return }
    guard let sourceView = draggingState.sourceView else { return }
    guard sourceView.frame != draggingState.initialFrame else {
      draggingState.didChangeFrame = false
      return
    }
    
    var frame = draggingGroup.frame
    frame.origin = sourceView.frame.origin.scale(by: canvasView.scale.inverse)
    draggingGroup.update(frame: frame)
    draggingState.didChangeFrame = true
    canvasState = .groupDragging(draggingGroup)
    actionDispatcher.dispatch(UpdateGroupAction(group: draggingGroup, reposition: true))
  }
  
  private func resizeGroup(position: GroupResizePosition, at point: CGPoint, reposition: Bool) {
    guard let page = stateStore.state.selectedPage else { return }
    guard var draggingGroup = currentDraggingGroup else { return }
    let dx = point.x - draggingState.initialPoint.x
    let minWidth = Group.minWidth
    var resultingFrame = draggingState.initialFrame
    switch position {
    case .topLeft, .left, .bottomLeft:
      resizeGroupLeft(frame: &resultingFrame, dx: dx, minWidth: minWidth)
    case .topRight, .right, .bottomRight:
      resizeGroupRight(frame: &resultingFrame, dx: dx, minWidth: minWidth)
    }
    let intersection = page.intersectingRegion(with: resultingFrame, excluding: draggingGroup)
    resultingFrame = resultingFrame.subtractFromNearestHorizonalSide(rect: intersection)
    draggingGroup.update(frame: resultingFrame.scale(by: canvasView.scale.inverse))
    draggingState.didChangeFrame = resultingFrame != draggingState.initialFrame
    canvasState = .groupResizing(draggingGroup, position)
    actionDispatcher.dispatch(UpdateGroupAction(group: draggingGroup, reposition: reposition))
  }
  
  private func resizeGroupLeft(frame: inout CGRect, dx: CGFloat, minWidth: CGFloat) {
    let maxX = frame.maxX
    var x = frame.minX + dx
    if frame.maxX - x < minWidth {
      x = maxX - minWidth
    }
    let width = frame.maxX - x
    frame.origin.x = x
    frame.size.width = width
  }
  
  private func resizeGroupRight(frame: inout CGRect, dx: CGFloat, minWidth: CGFloat) {
    var maxX = frame.maxX + dx
    if maxX - frame.minX < minWidth {
      maxX = frame.minX + minWidth
    }
    let width = maxX - frame.minX
    frame.size.width = width
  }
}

extension CanvasViewController {
  // MARK: Pinching
  
  @objc fileprivate func handlePinch(_ gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
    case .began, .changed:
      let location = gesture.location(in: canvasView)
      if pinchStartState == nil {
        pinchStartState = PinchStartState(contentOffset: canvasView.contentOffset,
                                          scale: canvasView.scale,
                                          windowLocation: canvasView.convert(location, to: view))
      }
      guard let startState = pinchStartState else { return }
      let targetScale = startState.scale * gesture.scale
      rootView.setCanvasScale(targetScale)
//      canvasView.contentOffset = startState.contentOffset.scale(by: targetScale.inverse)
      
      let anchorPoint = CGPoint(x: startState.windowLocation.x / view.frame.width,
                                y: startState.windowLocation.y / view.frame.height)

      var contentOffset = self.contentOffset(previousScale: startState.scale,
                                             previousContentOffset: startState.contentOffset,
                                             anchorPoint: anchorPoint)
      
      let locationInWindow = gesture.location(in: view)
      let windowTranslation = CGPoint(x: locationInWindow.x - startState.windowLocation.x,
                                      y: locationInWindow.y - startState.windowLocation.y)

      contentOffset.x -= windowTranslation.x
      contentOffset.y -= windowTranslation.y
      canvasView.contentOffset = contentOffset
      print("contentOffset: \(canvasView.contentOffset)")
    default:
      pinchStartState = nil
    }
  }
  
  private func contentOffset(previousScale: CGFloat,
                             previousContentOffset: CGPoint,
                             anchorPoint: CGPoint) -> CGPoint {
    
    guard canvasView.scale != previousScale else {
      return canvasView.contentOffset
    }
    
    let anchorLocation = CGPoint(x: anchorPoint.x * canvasView.frame.width,
                                 y: anchorPoint.y * canvasView.frame.height)
    
    var previousCenteredOffset = previousContentOffset
    previousCenteredOffset.x += anchorLocation.x
    previousCenteredOffset.y += anchorLocation.y
    
    var x = (previousCenteredOffset.x / previousScale) * canvasView.scale
    x -= anchorLocation.x
    
    var y = (previousCenteredOffset.y / previousScale) * canvasView.scale
    y -= anchorLocation.y
    
    return CGPoint(x: x, y: y)
  }
}

extension CanvasViewController {
  // MARK: Zooming
  
  func resetZoom() {
    rootView.setCanvasScale(1.0)
  }
  
  func zoomOut() {
    rootView.setCanvasScale(canvasView.scale / 2.0)
    reloadTextEditor()
  }
  
  func zoomIn() {
    rootView.setCanvasScale(canvasView.scale * 2.0)
    reloadTextEditor()
  }
}
