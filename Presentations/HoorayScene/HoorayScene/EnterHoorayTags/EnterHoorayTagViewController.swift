//
//  EnterHoorayTagViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EnterHoorayTagViewController

public final class EnterHoorayTagViewController: BaseViewController, EnterHoorayTagScene {
    
    let viewModel: EnterHoorayTagViewModel
    
    public init(viewModel: EnterHoorayTagViewModel) {
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

extension EnterHoorayTagViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension EnterHoorayTagViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}
