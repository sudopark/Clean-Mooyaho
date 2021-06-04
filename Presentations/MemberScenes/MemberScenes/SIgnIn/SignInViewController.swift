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

import Domain
import CommonPresenting


// MARK: - SignInViewController

public final class SignInViewController: BaseViewController, SignInScene {
    
    private let signInView = SignInView()
    let viewModel: SignInViewModel
    
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
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let types = self.viewModel.supportingOAuthProviderTypes
                types.forEach(self.appendAndBindButtons(_:))
                
                self.bindIsSigning()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func appendAndBindButtons(_ type: OAuthServiceProviderType) {
        guard let button = type.makeButton() else { return }
        
        self.signInView.appendSignInButton(button)
        
        let tapping: Observable<Void> = {
            switch button {
            case let uibutton as UIButton:
                return uibutton.rx.tap.asObservable()
            case let view as UIView:
                return view.rx.addTapgestureRecognizer().map{ _ in }
            }
        }()
        tapping
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.requestSignIn(type)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindIsSigning() {
        
        self.viewModel.isProcessing
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isProcessing in
                self?.signInView.updateIsActive(isProcessing == false)
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


private extension OAuthServiceProviderType {
    
    func makeButton() -> SignInButton? {
        guard let definedTypes = self as? OAuthServiceProviderTypes else { return nil }
        switch definedTypes {
        case .kakao:
            let button = UIButton()
            button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
            return button
            
        case .apple:
            return nil
        }
    }
}
