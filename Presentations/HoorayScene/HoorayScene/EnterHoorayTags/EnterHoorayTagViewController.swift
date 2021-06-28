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
    let titleLabel = UILabel()
    let tagInputView = TextTagInputField()
    let confirmButton = UIButton(type: .system)
    
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
        
        self.bottomSlideMenuView.bindKeyboardFrameChangesIfPossible()?
            .disposed(by: self.disposeBag)
        
        self.view.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.close()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let tags = self.tagInputView.getAllTags().map{ $0.text }
                self.viewModel.goNextInputStage(with: tags)
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                _ = self?.tagInputView.becomeFirstResponder()
            })
            .disposed(by: self.disposeBag)
        
        self.setupPreviousInputTags(self.viewModel.previousInputTags)
    }
    
    private func setupPreviousInputTags(_ tags: [String]) {
        
        
    }
}

// MARK: - setup presenting

extension EnterHoorayTagViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
        
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        self.bottomSlideMenuView.containerView.addSubview(tagInputView)
        tagInputView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        }
        tagInputView.setContentCompressionResistancePriority(.required, for: .vertical)
        tagInputView.autoLayout.active {
            $0.heightAnchor.constraint(lessThanOrEqualToConstant: 150)
        }
        tagInputView.setupLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: tagInputView.bottomAnchor, constant: 30)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        self.uiContext.deco.title(self.titleLabel)
        self.titleLabel.text = "Enter a tags"
        
        self.tagInputView.setupStyling()
        
        self.confirmButton.layer.cornerRadius = 5
        self.confirmButton.clipsToBounds = true
        self.confirmButton.backgroundColor = UIColor.systemBlue
        self.confirmButton.setTitle("Confirm", for: .normal)
        self.confirmButton.setTitleColor(.white, for: .normal)
    }
}
