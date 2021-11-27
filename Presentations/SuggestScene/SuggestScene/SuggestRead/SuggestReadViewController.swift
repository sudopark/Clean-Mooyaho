//
//  SuggestReadViewController.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - SuggestReadViewController

public final class SuggestReadViewController: BaseViewController, SuggestReadScene {
    
    let viewModel: SuggestReadViewModel
    
    public init(viewModel: SuggestReadViewModel) {
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

extension SuggestReadViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension SuggestReadViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}
