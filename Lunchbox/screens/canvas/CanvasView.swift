//
//  CanvasView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 7/7/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

protocol CanvasDelegate: class {
  var canvasState: CanvasState { get }
  var editingBlockItem: BlockItem? { get }
  func isSelected(group: Group) -> Bool
}

class CanvasView: NiblessScrollView {
  
  fileprivate let contentView = UIView()
  
  let contentMargin: CGFloat = 50.0
  
  let editingTextView: UITextView = {
    let textView = UITextView()
    textView.applyCommonBlockTextStyle()
    textView.autocorrectionType = .no
    return textView
  }()
  
  init() {
    super.init(frame: .zero)
    addSubview(contentView)
    minimumZoomScale = 1.0 / 8.0
    maximumZoomScale = 1.0
    showsVerticalScrollIndicator = false
    showsHorizontalScrollIndicator = false
    contentInsetAdjustmentBehavior = .never
    bouncesZoom = false
    delegate = self
    contentInset = UIEdgeInsets(top: contentMargin,
                                left: contentMargin,
                                bottom: contentMargin,
                                right: contentMargin)
  }
  
  private var _scale: CGFloat = 1.0
  var scale: CGFloat {
    get { return _scale }
    set {
      _scale = max(min(newValue, maximumZoomScale), minimumZoomScale)
      reload()
    }
  }
  
  fileprivate var clampContentOffset = false
  fileprivate var clampNextContentOffset = false {
    didSet {
      if clampNextContentOffset {
        clampOldContentOffset = contentOffset
      }
    }
  }
  fileprivate var clampOldContentOffset = CGPoint.zero
  fileprivate var contentOffsetClampValue = CGPoint.zero
  
  weak var canvasDelegate: CanvasDelegate?
  fileprivate var canvasState: CanvasState { return canvasDelegate?.canvasState ?? .none }
  
  var groups: [Group] {
    get { return groupMap.map { $0.1 } }
    set {
      groupMap = newValue.reduce([String: Group]()) { (cur, group) -> [String: Group] in
        var cur = cur
        cur[group.id] = group
        return cur
      }
      updateContentSize()
      clearAllViews()
      reload()
    }
  }
  
  fileprivate var groupMap = [String: Group]()
  fileprivate var groupViewMap = [String: GroupView]()

  fileprivate let zoomIncrementFactor: CGFloat = 2.0
  
  fileprivate var editingTextViewConstraints = [NSLayoutConstraint]()
  fileprivate var lastEditingItem: BlockItem?

  func reload() {
    reload(groups: groups)
  }
  
  func reload(group: Group) {
    reload(groups: [group])
  }
  
  func reload(groups: [Group]) {
    var selectedView: GroupView?
    groups.forEach { group in
      groupMap[group.id] = group
      reloadView(group: group)
      if canvasDelegate?.isSelected(group: group) ?? false {
        selectedView = groupView(for: group)
      }
    }
    if let view = selectedView {
      view.superview?.bringSubviewToFront(view)
    }
    updateContentSize()
    adjustContentInsets()
  }
  
  private func updateContentSize() {
    struct FrameDistance {
      let frame: CGRect
      let distance: CGFloat
    }
    let distances: [FrameDistance] = groups.map {
      let maxPoint = CGPoint(x: $0.frame.maxX, y: $0.frame.maxY)
      let distance = maxPoint.distance(to: .zero)
      return FrameDistance(frame: $0.frame, distance: distance)
    }
    let furthestFrame = (distances.sorted { $0.distance < $1.distance }).last?.frame ?? .zero
    contentSize = CGSize(width: furthestFrame.maxX, height: furthestFrame.maxY)
    contentView.frame = CGRect(origin: .zero, size: contentSize)
  }
  
  private func adjustContentInsets() {
    let containerSize = bounds.size
    let leftInset = contentMargin //max((containerSize.width - contentSize.width) / 2.0, contentMargin)
    let topInset = contentMargin //max((containerSize.height - contentSize.height) / 2.0, contentMargin)
    contentInset = UIEdgeInsets(top: topInset, left: leftInset, bottom: contentMargin, right: contentMargin)
  }
}

extension CanvasView {
  // MARK: View Loading
  
  fileprivate func clearAllViews() {
    groupViewMap.values.forEach { $0.removeFromSuperview() }
    groupViewMap.removeAll()
  }
  
  fileprivate func clearView(group: Group) {
    let key = group.id
    groupViewMap[key]?.removeFromSuperview()
    groupViewMap.removeValue(forKey: key)
  }
  
  private func isHidden(group: Group) -> Bool {
    switch canvasState {
    case .groupDragging(let draggingGroup):
      return (group == draggingGroup)
    default:
      return false
    }
  }
  
  func blockTextView(at point: CGPoint) -> BlockGroupedTextView? {
    guard let groupView = self.groupView(at: point) else { return nil }
    let localPoint = groupView.convert(point, from: self)
    guard let view = groupView.blockView(at: localPoint) else { return nil }
    return view as? BlockGroupedTextView
  }
  
  func blockTextView(for blockItem: BlockItem) -> BlockGroupedTextView? {
    guard let groupView = self.groupView(for: blockItem.group) else { return nil }
    guard let view = groupView.blockView(for: blockItem) else { return nil }
    return (view as? BlockGroupedTextView)
  }

  private func groupFrame(for group: Group) -> CGRect {
    let size = GroupView.size(for: group, editingItem: canvasDelegate?.editingBlockItem)
    return CGRect(origin: group.frame.origin, size: size).scale(by: scale)
  }

  fileprivate func reloadView(group: Group) {
    guard visibleRect.intersects(group.frame), !isHidden(group: group) else {
      clearView(group: group)
      return
    }
    let view = groupViewMap[group.id] ?? loadGroupView(group: group)
    view.frame = groupFrame(for: group)
    view.update(group: group, canvasState: canvasState, scale: scale)
    updateEditingTextViewIfNecessary(for: group, groupView: view)
  }
  
  private func loadGroupView(group: Group) -> GroupView {
    let view = GroupView(group: group)
    contentView.addSubview(view)
    groupViewMap[group.id] = view
    return view
  }
}

extension CanvasView {
  // MARK: Text Editing
  
  private func clearTextEditingViewConstraints() {
    editingTextViewConstraints.forEach { c in
      c.isActive = false
      editingTextView.removeConstraint(c)
      editingTextView.superview?.removeConstraint(c)
    }
    editingTextViewConstraints.removeAll()
  }
  
  private func updateTextEditingViewConstraints(sourceTextView: BlockGroupedTextView) {
    clearTextEditingViewConstraints()
    guard editingTextView.superview != nil else { return }
    let textView = sourceTextView.textView
    let centerX = editingTextView.centerX(to: textView)
    let centerY = editingTextView.centerY(to: textView)
    let width = editingTextView.alignWidth(to: textView)
    let height = editingTextView.alignHeight(to: textView)
    editingTextViewConstraints = [centerX, centerY, width, height]
  }
  
  fileprivate func updateEditingTextViewIfNecessary(for group: Group, groupView: GroupView) {
    guard let item = lastEditingItem else { return }
    for idx in 0..<group.blocks.count {
      let block = group.blocks[idx]
      if item.group == group, item.block == block {
        if let sourceTextView = groupView.blockTextView(atIndex: idx) {
          updateTextEditingViewConstraints(sourceTextView: sourceTextView)
        }
      }
    }
  }
  
  func startTextEditing(item: BlockItem, sourceTextView: BlockGroupedTextView) {
    addSubview(editingTextView)
    clipsToBounds = false
    lastEditingItem = item
    if item.block.text.count > 0 {
      editingTextView.attributedText = sourceTextView.textView.attributedText
    } else {
      let attributes = sourceTextView.textView.attributedText?.attributes(at: 0, effectiveRange: nil) ?? [:]
      editingTextView.attributedText = NSAttributedString(string: "", attributes: attributes)
      editingTextView.typingAttributes = attributes
    }
    editingTextView.becomeFirstResponder()
  }
  
  func updateTextEditing(item: BlockItem, sourceTextView: BlockGroupedTextView) {
    lastEditingItem = item
    bringSubviewToFront(editingTextView)
    if item.block.text.count > 0 {
      editingTextView.attributedText = sourceTextView.textView.attributedText
    }
  }
  
  func endTextEditing() {
    lastEditingItem = nil
    clearTextEditingViewConstraints()
    editingTextView.resignFirstResponder()
    editingTextView.removeFromSuperview()
    clipsToBounds = true
  }
}

extension CanvasView {
  // MARK: Queries
  
  func group(at point: CGPoint) -> Group? {
    return groupView(at: point)?.group
  }
  
  func block(at point: CGPoint) -> BlockItem? {
    guard let groupView = groupView(at: point) else { return nil }
    let localPoint = groupView.convert(point, from: self)
    guard let blockItem = groupView.block(at: localPoint) else { return nil }
    return blockItem
  }
  
  func groupView(at point: CGPoint) -> GroupView? {
    for v in groupViewMap.values {
      if v.frame.contains(point) {
        return v
      }
    }
    return nil
  }
  
  func groupView(for group: Group) -> GroupView? {
    return groupViewMap[group.id]
  }
  
  func closestBlockView(at point: CGPoint) -> BlockView? {
    guard let groupView = groupView(at: point) else { return nil }
    let localPoint = convert(point, to: groupView)
    return groupView.closestBlockView(at: localPoint)
  }

  func blockView(at point: CGPoint) -> BlockView? {
    guard let groupView = groupView(at: point) else { return nil }
    let localPoint = convert(point, to: groupView)
    return groupView.blockView(at: localPoint)
  }
}

extension CanvasView {
  fileprivate var visibleRect: CGRect {
    return convert(bounds, to: contentView)
  }
}

extension CanvasView {
  // MARK: Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    reload()
  }
}

extension CanvasView: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("co: \(scrollView.contentOffset)")
  }
}
