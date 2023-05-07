//
//  InnerWebViewViewController.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Prelude

import Domain
import CommonPresenting
import Extensions
import SwiftUI


// MARK: - InnerWebViewViewController

public final class InnerWebViewViewController: UIHostingController<InnerWebView_SwiftUI>, InnerWebViewScene, BaseViewControllable  {
    
    let viewModel: InnerWebViewViewModel
    
    public init(viewModel: InnerWebViewViewModel) {
        self.viewModel = viewModel
        
        let webView = InnerWebView_SwiftUI(viewModel: viewModel)
        super.init(rootView: webView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
}
