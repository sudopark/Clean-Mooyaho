//
//  EnterHoorayMessageViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EnterHoorayMessageViewController

public final class EnterHoorayMessageViewController: BaseViewController, EnterHoorayMessageScene {
    
    let bottomSlideMenuView = BaseBottomSlideMenuView()
    let messageInputView = UITextView()
    let placeHolderLabel = UILabel()
    let charCountLabel = UILabel()
    let toolBar = HoorayActionToolbar()
    let viewModel: EnterHoorayMessageViewModel
    
    private let maxInputMessageCount: Int = 100
    
    public init(viewModel: EnterHoorayMessageViewModel) {
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

extension EnterHoorayMessageViewController {
    
    private func bind() {
        
        self.messageInputView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.updatePlaceHolder(text)
                self?.updateCharCount(text)
                self?.viewModel.updateText(text)
            })
            .disposed(by: self.disposeBag)
        
        self.toolBar.nextButton?.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.goNextInputStage()
            })
            .disposed(by: self.disposeBag)
        
        let previousText = self.viewModel.previousInputText ?? ""
        self.messageInputView.text = previousText
        self.placeHolderLabel.isHidden = previousText.isNotEmpty
        
        self.viewModel.isNextButtonEnabled
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] enabled in
                self?.toolBar.nextButton?.isEnabled = enabled
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updatePlaceHolder(_ text: String) {
        self.placeHolderLabel.isHidden = text.isNotEmpty
    }
    
    private func updateCharCount(_ text: String) {
        self.charCountLabel.text = "\(text.count)/\(self.maxInputMessageCount)"
    }
}

// MARK: - setup presenting

extension EnterHoorayMessageViewController: Presenting, UITextViewDelegate {
    
    
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
        
        self.bottomSlideMenuView.addSubview(messageInputView)
        messageInputView.autoLayout.active(with: bottomSlideMenuView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.bottomAnchor.constraint(equalTo: toolBar.topAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
            $0.heightAnchor.constraint(equalToConstant: 220)
        }
        
        self.bottomSlideMenuView.addSubview(placeHolderLabel)
        placeHolderLabel.autoLayout.active(with: bottomSlideMenuView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
        }
        
        self.bottomSlideMenuView.addSubview(charCountLabel)
        charCountLabel.autoLayout.active(with: bottomSlideMenuView) {
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        self.messageInputView.textColor = self.uiContext.colors.text
        self.placeHolderLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.7)
        self.placeHolderLabel.text = "Enter a message"
        self.charCountLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.7)
        self.charCountLabel.text = "0/100"
        
        self.messageInputView.delegate = self
        
        self.toolBar.showSkip = false
        self.toolBar.nextButton?.isEnabled = false
    }
    
    public func textView(_ textView: UITextView,
                         shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let newTextCount = (textView.text + text).count
        guard newTextCount <= self.maxInputMessageCount else { return false }
        return true
    }
}
