//
//  MainViewController.swift
//  Lunchbox
//
//  Created by Nick Bolton on 1/15/19.
//  Copyright © 2019 Pixelbleed, LLC. All rights reserved.
//

import UIKit
import MobileKit

class MainViewController: NiblessViewController, TransitionAnimatable {
  
  private let transitionManager = AnimatorTransitionManager()
  
  // MARK: View Lifecycle
  
  override func loadView() {
    view = MainRootView()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentDocumentBrowser()
  }
  
  // MARK: Helpers
  
  private func presentDocumentBrowser() {
    let vc = DocumentBrowserViewController()
    present(vc, animated: false)
  }
  
  // MARK: TransitionAnimatable Conformance
  
  func animators(with context: TransitionContext) -> [Animator] {
    return []
  }
  
  func setupTransition(with context: TransitionContext, delay: inout TimeInterval) {
    delay = 1.0
  }
  
  func finishTransition(with context: TransitionContext) {
  }
}
