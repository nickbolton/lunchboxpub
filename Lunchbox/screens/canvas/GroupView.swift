//
//  GroupView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/23/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

protocol GroupDelegate: class {
  func didTapBlock(group: Group, block: Block, sourceTextView: UITextView?)
  func didTapGroup(group: Group)
  var ds: [[CollectionItem]]? { get }
}

enum GroupResizePosition: CaseIterable {
  case topLeft
  case topRight
  case left
  case right
  case bottomLeft
  case bottomRight
}

fileprivate struct PotentialBlockMatch {
  let blockView: BlockView
  let distance: CGFloat
}

class GroupView: NiblessView {
  
  init(group: Group) {
    self.group = group
    super.init(frame: .zero)
  }
  
  private let blockContainer = UIView()

  private (set) var canvasState = CanvasState.none
  private (set) var group: Group
  private (set) var scale: CGFloat = 1.0 {
    didSet {
      if scale != oldValue {
        updateBlockContainerMarginConstraints()
      }
    }
  }
  
  private let defaultCornerRadius: CGFloat = 20.0
  private let defaultBorderWidth: CGFloat = 3.0
  private let defaultShadow = SketchShadow(color: .black, opacity: 0.2, x: 0.0, y: 16.0, blur: 11.0, spread: 0.0)
  
  var isDragging = false { didSet { setNeedsDisplay() } }
  
  private let sizer = GroupSizer()
  
  private var blockContainerLeftConstraint: NSLayoutConstraint!
  private var blockContainerRightConstraint: NSLayoutConstraint!

  func update(group: Group, canvasState: CanvasState, scale: CGFloat) {
    self.group = group
    self.canvasState = canvasState
    self.scale = scale
    setNeedsDisplay()
  }
  
  override var frame: CGRect {
    didSet {
      if frame.size != oldValue.size {
        buildBlockViews()
      }
    }
  }
  
  var editingItem: BlockItem? {
    switch canvasState {
    case .blockTextEditing(let blockItem):
      return blockItem
    default:
      return nil
    }
  }

  var draggingSourceItem: BlockItem? {
    switch canvasState {
    case .blockDragging(let blockItem):
      return blockItem
    default:
      return nil
    }
  }
  
  var draggingGroup: Group? {
    switch canvasState {
    case .groupDragging(let group):
      return group
    default:
      return nil
    }
  }
  
  weak var delegate: GroupDelegate?
  
  static private let titleMargins: CGFloat = 30.0
  
  var isHighlighted = false { didSet { alpha = isHighlighted ? 0.5 : 1.0 } }
  
  func setBlockHighlighted(blockItem: BlockItem, highlighted: Bool) {
    blockView(for: blockItem)?.alpha = highlighted ? 0.5 : 1.0
  }
  
  func clearBlockHighlighting() {
    blockContainer.subviews.forEach { $0.alpha = 1.0 }
  }
  
  static func size(for group: Group, editingItem: BlockItem?) -> CGSize {
    return GroupSizer().size(for: group, editingItem: editingItem)
  }
  
  static func height(for group: Group, editingItem: BlockItem?) -> CGFloat {
    return GroupSizer().height(for: group, editingItem: editingItem)
  }
    
  // MARK: View Hierarchy Construction
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(blockContainer)
    addHandleViews()
  }
  
  private func addHandleViews() {
    for pos in GroupResizePosition.allCases {
      let view = HandleView(position: pos)
      addSubview(view)
    }
  }
  
  override func activateConstraints() {
    super.activateConstraints()
    constrainBlockContainer()
    constrainHandleViews()
  }
  
  private func constrainBlockContainer() {
    blockContainerLeftConstraint = blockContainer.alignLeft(offset: sizer.sideMargins)
    blockContainerRightConstraint = blockContainer.alignRight(offset: -sizer.sideMargins)
    blockContainer.alignTop()
  }
  
  private func constrainHandleViews() {
    let size = CGSize(width: 10.0, height: 10.0)
    enumerateHandleViews { view in
      view.layout(size: size)
      switch view.position {
      case .topLeft:
        view.alignTop(offset: -size.height / 2.0)
        view.alignLeft(offset: -size.width / 2.0)
      case .topRight:
        view.alignTop(offset: -size.height / 2.0)
        view.alignRight(offset: size.width / 2.0)
      case .left:
        view.alignLeft(offset: -size.width / 2.0)
        view.centerY()
      case .right:
        view.alignRight(offset: size.width / 2.0)
        view.centerY()
      case .bottomLeft:
        view.alignBottom(offset: size.height / 2.0)
        view.alignLeft(offset: -size.width / 2.0)
      case .bottomRight:
        view.alignBottom(offset: size.height / 2.0)
        view.alignRight(offset: size.width / 2.0)
      }
    }
  }
  
  // MARK: Theme
  
  override func applyTheme() {
    super.applyTheme()
    layer.cornerRadius = defaultCornerRadius * scale
    layer.borderWidth = defaultBorderWidth * scale
    layer.applySketchShadow(color: defaultShadow.color,
                            opacity: defaultShadow.opacity,
                            x: defaultShadow.x * scale,
                            y: defaultShadow.y * scale,
                            blur: defaultShadow.blur * scale,
                            spread: defaultShadow.spread * scale)

    buildBlockViews()
    backgroundColor = Design.shared.groupBackgroundColor
    alpha = isDragging ? 0.5 : 1.0
    clearSelectedState()
    switch canvasState {
    case .groupSelected(let selectedItem):
      if selectedItem == group {
        setSelectedState()
      }
    case .groupResizing(let selectedItem, _):
      if selectedItem == group {
        setSelectedState()
      }
    default:
      break
    }
  }
  
  // MARK: Helpers
  
  private func enumerateHandleViews(_ handler: (HandleView)->Void) {
    for v in subviews {
      guard let handleView = v as? HandleView else { continue }
      handler(handleView)
    }
  }
  
  func handlePosition(at point: CGPoint) -> GroupResizePosition? {
    
    struct PositionDistance {
      let position: GroupResizePosition
      let distance: CGFloat
    }
    
    let distanceThreshold: CGFloat = 22.0
    var distances = [PositionDistance]()
    enumerateHandleViews { v in
      let distance = v.frame.distance(to: point)
      if distance <= distanceThreshold {
        distances.append(PositionDistance(position: v.position, distance: distance))
      }
    }
    return (distances.sorted { $0.distance < $1.distance }).first?.position
  }
    
  func block(at point: CGPoint) -> BlockItem? {
    for v in blockContainer.subviews {
      guard let blockView = v as? BlockView else { continue }
      guard blockView.frame.contains(point) else { continue }
      return blockView.blockItem
    }
    return nil
  }
  
  func closestBlockView(at point: CGPoint) -> BlockView? {
    let touchSize: CGFloat = 44.0
    let halfSize = touchSize / 2.0
    let testRect = CGRect(x: point.x - halfSize,
                          y: point.y - halfSize,
                          width: touchSize,
                          height: touchSize)
    var potentials = [PotentialBlockMatch]()
    for v in blockContainer.subviews {
      guard let blockView = v as? BlockView else { continue }
      guard blockView.frame.intersects(testRect) else { continue }
      let distance = blockView.center.distance(to: point)
      let potential = PotentialBlockMatch(blockView: blockView, distance: distance)
      potentials.append(potential)
    }
    return (potentials.sorted { $0.distance < $1.distance }).first?.blockView
  }
  
  func blockView(at point: CGPoint) -> BlockView? {
    for v in blockContainer.subviews {
      guard let blockView = v as? BlockView else { continue }
      guard blockView.frame.contains(point) else { continue }
      return blockView
    }
    return nil
  }
  
  func blockView(for blockItem: BlockItem) -> BlockView? {
    for idx in 0..<blockContainer.subviews.count {
      guard let blockView = blockContainer.subviews[idx] as? BlockView else { continue }
      if blockView.blockItem == blockItem {
        return blockView
      }
    }
    return nil
  }
  
  func blockTextView(atIndex idx: Int) -> BlockGroupedTextView? {
    guard idx >= 0, idx < group.blocks.count, idx < blockContainer.subviews.count else { return nil }
    if let view = blockContainer.subviews[idx] as? BlockGroupedTextView {
      view.applyTheme()
      return view
    }
    return nil
  }
  
  func blockViews(excluding: BlockItem) -> [BlockView] {
    var result = [BlockView]()
    for v in blockContainer.subviews {
      guard let blockView = v as? BlockView else { continue }
      guard blockView.blockItem != excluding else { continue }
      result.append(blockView)
    }
    return result
  }
  
  private func buildBlockViews() {
    blockContainer.subviews.forEach { $0.removeFromSuperview() }
    guard bounds.width > 0.0 else { return }
    let contentWidth = (bounds.width * scale.inverse) - (2.0 * sizer.sideMargins)
    let factory = BlockViewFactory()
    var yPos: CGFloat = 0.0
    for idx in 0..<group.blocks.count {
      var block = group.blocks[idx]
      if block == editingItem?.block {
        block = editingItem!.block
      }
      let isEditingText = (block == editingItem?.block)
      let view = factory.buildBlockView(block: block, in: group)
      view.tag = idx
      view.isHidden = (block == draggingSourceItem?.block)
      if (draggingGroup?.blocks.filter { $0 == block })?.count ?? 0 > 0 {
        view.isHidden = true
      }
      if let textEditingView = view as? TextEditingView {
        textEditingView.textView.isHidden = isEditingText
      }
      if let blockView = view as? BlockView {
        blockView.blockItem = BlockItem(group: group, block: block)
        blockView.canvasState = canvasState
        blockView.scale = scale
      }
      view.applyTheme()
      let height = factory.height(for: block, in: group, contentWidth: contentWidth, isEditingText: isEditingText)
      blockContainer.addSubview(view)
      view.frame = CGRect(x: 0.0, y: yPos, width: contentWidth, height: height).scale(by: scale)
      yPos += height + sizer.blockSpacing
    }
  }
  
  private func clearSelectedState() {
    layer.borderColor = Design.shared.groupBorderColor.cgColor
    enumerateHandleViews { $0.isHidden = true }
  }
  
  private func setSelectedState() {
    layer.borderColor = Design.shared.selectedBorderColor.cgColor
    enumerateHandleViews { $0.isHidden = false }
  }
  
  private func updateBlockContainerMarginConstraints() {
    blockContainerLeftConstraint.constant = sizer.sideMargins * scale
    blockContainerRightConstraint.constant = -sizer.sideMargins * scale
  }
}
