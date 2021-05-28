//
//  SignInViewController.swift
//  MemberScenes
//
//  Created sudo.park on 2021/05/29.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SignInScene

public protocol SignInScene: Scenable, PangestureDismissableScene { }


// MARK: - SignInViewController

public final class SignInViewController: BaseViewController, SignInScene {
    
    private let viewModel: SignInViewModel
    
    public init(viewModel: SignInViewModel) {
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
    }
    
}

// MARK: - bind

extension SignInViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension SignInViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}
