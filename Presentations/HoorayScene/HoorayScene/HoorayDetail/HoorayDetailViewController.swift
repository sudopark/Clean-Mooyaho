//
//  HoorayDetailViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/08/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - HoorayDetailViewController

public final class HoorayDetailViewController: BaseViewController, HoorayDetailScene {
    
    let viewModel: HoorayDetailViewModel
    
    public init(viewModel: HoorayDetailViewModel) {
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

extension HoorayDetailViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension HoorayDetailViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}
