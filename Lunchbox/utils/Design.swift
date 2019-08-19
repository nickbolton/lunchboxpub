//
//  Design.swift
//  Canvas
//
//  Created by Nick Bolton on 12/9/18.
//  Copyright © 2018 Pixelbleed LLC. All rights reserved.
//

import UIKit
import MobileKit

class Design: NSObject {
  
  static let shared = Design()
  override private init() { super.init() }
  
  private (set) var canvasBackgroundColor = UIColor.clear
  private (set) var headerBackgroundColor = UIColor.clear
  private (set) var headerShadow = SketchShadow(color: .clear, opacity: 0.0, x: 0.0, y: 0.0, blur: 0.0, spread: 0.0)
  private (set) var toolControlTintColor = UIColor.clear
  private (set) var toolControlBackgroundColor = UIColor.clear
  private (set) var toolControlSelectedBackgroundColor = UIColor.clear
  private (set) var layeredToolControlBackgroundColor = UIColor.clear
  private (set) var blockTextColor = UIColor.clear
  private (set) var groupBorderColor = UIColor.clear
  private (set) var selectedBorderColor = UIColor.clear
  private (set) var groupBackgroundColor = UIColor.clear
  private (set) var panelBackgroundColor = UIColor.clear
  private (set) var panelTitleColor = UIColor.clear
  private (set) var panelDividerColor = UIColor.clear
  private (set) var panelHandleColor = UIColor.clear
  private (set) var panelItemColor = UIColor.clear
  private (set) var blockBackgroundColor = UIColor.clear

  private (set) var blurEffect = UIBlurEffect(style: .dark)

  var isDarkMode = false {
    didSet {
      
      if (isDarkMode) {
        blurEffect = UIBlurEffect(style: .dark)
        canvasBackgroundColor = UIColor(hex: 0x1D1E1F)
        headerBackgroundColor = UIColor(hex: 0x45474B).color(withAlpha: 0.7)
        headerShadow = SketchShadow(color: .black, opacity: 0.1, x: 0.0, y: 1.0, blur: 4.0, spread: 0.0)
        toolControlTintColor = .white
        toolControlBackgroundColor = UIColor.white.color(withAlpha: 0.07)
        toolControlSelectedBackgroundColor = UIColor.black.color(withAlpha: 0.3)
        layeredToolControlBackgroundColor = UIColor.white.color(withAlpha: 0.1)
        blockTextColor = UIColor(hex: 0xDEDEDE)
        groupBorderColor = UIColor.white.color(withAlpha: 0.1)
        selectedBorderColor = UIColor(hex: 0x9D9D9D)
        groupBackgroundColor = UIColor(hex: 0x1A1A1A)
        panelBackgroundColor = UIColor(hex: 0x45474B).color(withAlpha: 0.7)
        panelTitleColor = .white
        panelDividerColor = UIColor(hex: 0x6B6B6B).color(withAlpha: 0.63)
        panelHandleColor = UIColor(hex: 0x8B8B8B).color(withAlpha: 0.5)
        panelItemColor = UIColor(hex: 0x494A4E)
        blockBackgroundColor = UIColor(hex: 0x2F2F2F)

      } else {
        blurEffect = UIBlurEffect(style: .light)
        canvasBackgroundColor = UIColor(hex: 0xEBEDF2)
        headerBackgroundColor = UIColor.white.color(withAlpha: 0.8)
        headerShadow = SketchShadow(color: .black, opacity: 0.1, x: 0.0, y: 1.0, blur: 4.0, spread: 0.0)
        toolControlTintColor = UIColor(hex: 0x2C303C)
        toolControlBackgroundColor = UIColor(hex: 0x1E274D).color(withAlpha: 0.07)
        toolControlSelectedBackgroundColor = UIColor.white.color(withAlpha: 0.3)
        layeredToolControlBackgroundColor = UIColor(hex: 0x1E274D).color(withAlpha: 0.1)
        blockTextColor = UIColor(hex: 0x2C303C)
        groupBorderColor = UIColor(hex: 0x2C303C)
        selectedBorderColor = UIColor(hex: 0xEEEEEE)
        groupBackgroundColor = UIColor(hex: 0xDEDEDE)
        panelBackgroundColor = UIColor(hex: 0x45474B).color(withAlpha: 0.7)
        panelTitleColor = .black
        panelDividerColor = UIColor(hex: 0x6B6B6B).color(withAlpha: 0.63)
        panelHandleColor = UIColor.black.color(withAlpha: 0.5)
        panelItemColor = UIColor(hex: 0xF7F9FC)
        blockBackgroundColor = UIColor(hex: 0xF7F9FC)
      }
    }
  }
}
