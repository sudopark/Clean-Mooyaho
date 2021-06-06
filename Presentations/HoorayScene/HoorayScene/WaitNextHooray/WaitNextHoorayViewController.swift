//
//  WaitNextHoorayViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - WaitNextHoorayViewController

public final class WaitNextHoorayViewController: BaseViewController, WaitNextHoorayScene {
    
    let viewModel: WaitNextHoorayViewModel
    
    public init(viewModel: WaitNextHoorayViewModel) {
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

extension WaitNextHoorayViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension WaitNextHoorayViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}
