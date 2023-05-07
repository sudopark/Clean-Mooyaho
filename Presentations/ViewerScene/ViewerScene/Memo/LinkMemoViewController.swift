//
//  LinkMemoViewController.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/24.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import SwiftUI

import CommonPresenting

// MARK: - LinkMemoViewController

public final class LinkMemoViewController: UIHostingController<LinkMemoView>, BaseViewControllable, LinkMemoScene {
    
    let viewModel: LinkMemoViewModel
    
    public init(viewModel: LinkMemoViewModel) {
        self.viewModel = viewModel
        let rootView = LinkMemoView(viewModel: viewModel)
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
}
