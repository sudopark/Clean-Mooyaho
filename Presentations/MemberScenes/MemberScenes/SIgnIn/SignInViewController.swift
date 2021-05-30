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
    
    private let signInView = SignInView()
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
        self.bind()
    }
    
}

// MARK: - bind

extension SignInViewController {
    
    private func bind() {
        
        self.signInView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.requestClose()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension SignInViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(signInView)
        signInView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        self.signInView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = .clear
        self.signInView.setupStyling()
    }
}
