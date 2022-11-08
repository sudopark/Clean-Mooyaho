//
//  FeedbackViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SwiftUI

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


// MARK: - FeedbackViewController

public final class FeedbackViewController: UIHostingController<FeedbackView>, BaseViewControllable, FeedbackScene {
    
    let viewModel: FeedbackViewModel
    
    public init(viewModel: FeedbackViewModel) {
        self.viewModel = viewModel
        let rootView = FeedbackView(viewModel: viewModel)
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}
