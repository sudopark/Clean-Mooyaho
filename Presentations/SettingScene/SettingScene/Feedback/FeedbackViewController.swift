//
//  FeedbackViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


// MARK: - FeedbackViewController

public final class FeedbackViewController: BaseViewController, FeedbackScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let messageInputView = InputTextView()
    private let contactLabel = UILabel()
    private let contactInputView = InputTextView()
    private let confirmButton = ConfirmButton()
    
    let viewModel: FeedbackViewModel
    
    
    public init(viewModel: FeedbackViewModel) {
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
    
    public func requestCloseScene() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - bind

extension FeedbackViewController {
    
    private func bind() {
        
        self.bindBottomSlideMenuView()
        
        self.messageInputView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.messageInputView.placeHolderLabel.isHidden = text.isNotEmpty == true
                self?.viewModel.enterMessage(text)
            })
            .disposed(by: self.disposeBag)
        
        self.contactInputView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.contactInputView.placeHolderLabel.isHidden = text.isNotEmpty == true
                self?.viewModel.enterContact(text)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isEnable in
                self?.confirmButton.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.register()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension FeedbackViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        bottomSlideMenuView.containerView.addSubview(self.confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        
        bottomSlideMenuView.containerView.addSubview(contactInputView)
        contactInputView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.bottomAnchor.constraint(equalTo: self.confirmButton.topAnchor, constant: -20)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        contactInputView.setContentCompressionResistancePriority(.required, for: .vertical)
        contactInputView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(contactLabel)
        contactLabel.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: contactInputView.topAnchor, constant: -8)
        }
        contactLabel.numberOfLines = 1
        contactLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        bottomSlideMenuView.containerView.addSubview(messageInputView)
        messageInputView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: contactLabel.topAnchor, constant: -16)
        }
        self.messageInputView.setupLayout()
        
        bottomSlideMenuView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: messageInputView.topAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ pure("Feedback".localized)
        
        self.messageInputView.setupMultilineStyling(120)
        self.messageInputView.placeHolderLabel.text = "Enter a message"
        self.uiContext.decorating.placeHolder(self.messageInputView.placeHolderLabel)
        
        _ = self.contactLabel
            |> self.uiContext.decorating.listSectionTitle(_:)
            |> \.text .~ pure("Contact".localized)
        
        self.contactInputView.setupSingleLineStyling()
        self.contactInputView.placeHolderLabel.text = "Please leave your email address to be contacted.".localized
        self.contactInputView.singleLineTextField.font = self.uiContext.fonts.get(13, weight: .regular)
        self.uiContext.decorating.placeHolder(self.contactInputView.placeHolderLabel)
        
        self.confirmButton.setupStyling()
        self.confirmButton.isEnabled = false
    }
}
