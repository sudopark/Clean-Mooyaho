//
//  InnerWebViewViewController.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - InnerWebViewViewController

public final class InnerWebViewViewController: BaseViewController, InnerWebViewScene {
    
    let viewModel: InnerWebViewViewModel
    
    public init(viewModel: InnerWebViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
}

// MARK: - bind

extension InnerWebViewViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension InnerWebViewViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
    }
}
