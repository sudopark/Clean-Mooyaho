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
    
    let bottomSlideMenuView = BaseBottomSlideMenuView()
    let tagInputView = TextTagInputField()
    let toolBar = HoorayActionToolbar()
    
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
        
        self.toolBar.skipButton?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.skipInput()
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.nextButton?.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let tags = self.tagInputView.getAllTags().map{ $0.text }
                self.viewModel.goNextInputStage(with: tags)
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension EnterHoorayTagViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.activeFill(self.view)
        bottomSlideMenuView.setupLayout()
        
        self.bottomSlideMenuView.addSubview(toolBar)
        toolBar.autoLayout.active(with: bottomSlideMenuView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.bottomSlideMenuView.addSubview(tagInputView)
        tagInputView.autoLayout.active(with: bottomSlideMenuView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.bottomAnchor.constraint(equalTo: toolBar.topAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
            $0.heightAnchor.constraint(equalToConstant: 220)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
    }
}
