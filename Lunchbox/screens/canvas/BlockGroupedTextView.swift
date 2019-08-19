//
//  BlockLabelBodyView.swift
//  Lunchbox
//
//  Created by Nick Bolton on 4/22/19.
//  Copyright © 2019 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

protocol BlockView where Self: NiblessView {
  var blockItem: BlockItem? { get set }
  var canvasState: CanvasState { get set }
  var scale: CGFloat { get set }
}

protocol TextEditingView where Self: NiblessView {
  var textView: UITextView { get }
  var isSelected: Bool { get set }
}

class BlockGroupedTextView: NiblessView, BlockView, TextEditingView {

  init(text: String, isTitle: Bool) {
    self.isTitle = isTitle
    super.init(frame: .zero)
    self.text = text
  }
    
  let textView: UITextView = {
    let textView = UITextView()
    textView.applyCommonBlockTextStyle()
    textView.isUserInteractionEnabled = false
    return textView
  }()
  
  private let defaultCornerRadius: CGFloat = 10.0
  private let defaultBorderWidth: CGFloat = 3.0
  
  static private let sideMargins: CGFloat = 17.0
  static private let verticalMargins: CGFloat = 20.0
  
  static func height(for block: Block, isTitle: Bool, isEditing: Bool, contentWidth contentWidthIn: CGFloat) -> CGFloat {
    let minHeight: CGFloat = isTitle ? 69.0 : 56.0
    let text = isEditing ? block.text : block.textOrDefault
    let style = isTitle ? titleTextStyle(text: text, scale: 1.0) : textStyle(text: text, scale: 1.0)
    let contentWidth = contentWidthIn - (2.0 * sideMargins) + 5.0
    let titleHeight = style.textViewHeight(inBoundingWidth: contentWidth)
    let result = titleHeight + (2.0 * verticalMargins)
    return max(result, minHeight)
  }
  
  let isTitle: Bool
  var text = ""
  var isSelected = false
  var blockItem: BlockItem?
  var canvasState = CanvasState.none
  var scale: CGFloat = 1.0
  
  func textViewFrame(in container: UIView) -> CGRect {
    return container.convert(textView.frame, from: self)
  }

  // MARK: Text Styles
  
  static func titleTextStyle(text: String, scale: CGFloat) -> TextStyle {
    let textColor = Design.shared.blockTextColor
    let font = UIFont.systemFont(ofSize: 24.0 * scale, weight: .bold)
    let descriptor = TextDescriptor(text: text, font: font, textColor: textColor, lineHeight: 28.8 * scale)
    return TextStyle(textDescriptors: [descriptor])
  }
  
  static func textStyle(text: String, scale: CGFloat) -> TextStyle {
    var label = text
    var body = ""
    if let pos = text.firstIndex(of: "\n") {
      label = String(text[...pos])
      if text.count > label.count {
        let next = text.index(after: pos)
        body = String(text[next...])
      }
    }
    let textColor = Design.shared.blockTextColor
    let labelFont = UIFont.systemFont(ofSize: 14.0 * scale, weight: .bold)
    let labelDescriptor = TextDescriptor(text: label, font: labelFont, textColor: textColor, lineHeight: 16.0 * scale)
    
    let bodyFont = UIFont.systemFont(ofSize: 14.0 * scale, weight: .regular)
    let bodyDescriptor = TextDescriptor(text: body, font: bodyFont, textColor: textColor, lineHeight: 18.0 * scale)

    return TextStyle(textDescriptors: [labelDescriptor, bodyDescriptor])
  }
  
  // MARK: View Hierarchy Construction
  
  override func constructHierarchy() {
    super.constructHierarchy()
    addSubview(textView)
  }
  
  override func applyTheme() {
    super.applyTheme()
    layer.cornerRadius = defaultCornerRadius * scale
    layer.borderWidth = defaultBorderWidth * scale
    if isTitle {
      textView.attributedText = type(of: self).titleTextStyle(text: text, scale: scale).attributedString
      backgroundColor = .clear
    } else {
      textView.attributedText = type(of: self).textStyle(text: text, scale: scale).attributedString
      backgroundColor = Design.shared.blockBackgroundColor
    }
    layoutTextView()
    layer.borderColor = UIColor.clear.cgColor
    switch canvasState {
    case .blockSelected(let selectedItem):
      if selectedItem == blockItem {
        layer.borderColor = Design.shared.selectedBorderColor.cgColor
        backgroundColor = Design.shared.blockBackgroundColor
      }
    default:
      break
    }
  }
  
  // MARK: Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layoutTextView()
  }
  
  private func layoutTextView() {
    guard bounds != .zero else { return }
    let horizontalOffset: CGFloat = -5.0
    let margins = (type(of: self).sideMargins + horizontalOffset) * scale
    let width = bounds.width - (2.0 * margins)
    textView.frame = CGRect(x: margins,
                            y: 0.0,
                            width: width,
                            height: 0.0)
    textView.sizeToFit()
    var frame = textView.frame
    frame.origin.y = (bounds.height - textView.frame.height) / 2.0
    textView.frame = frame
  }
}
