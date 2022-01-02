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

public final class SignInViewController: BaseViewController, SignInScene, BottomSlideViewSupporatble {
    
    private let signInView = SignInView()
    let viewModel: SignInViewModel
    private let oauthSignInButtonBuilder: OAuthSignInButtonBuildable
    
    public var bottomSlideMenuView: BaseBottomSlideMenuView { self.signInView.bottomSlideMenuView }
    
    public init(viewModel: SignInViewModel,
                oauthSignInButtonBuilder: OAuthSignInButtonBuildable) {
        self.viewModel = viewModel
        self.oauthSignInButtonBuilder = oauthSignInButtonBuilder
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.signInView.guideView.startAnimation()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.signInView.guideView.stopAnimation()
    }
    
    public func requestCloseScene() {
        self.viewModel.requestClose()
    }
    
}

// MARK: - bind

extension SignInViewController {
    
    private func bind() {
        
        self.bindBottomSlideMenuView()
        
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
        guard let button = self.oauthSignInButtonBuilder.makeButton(for: type) else { return }
        
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
                self?.signInView.loadingView.updateIsLoading(isProcessing)
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
        self.setupFullScreenLoadingViewLayout(self.signInView.loadingView)
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = .clear
        self.signInView.setupStyling()
    }
}
