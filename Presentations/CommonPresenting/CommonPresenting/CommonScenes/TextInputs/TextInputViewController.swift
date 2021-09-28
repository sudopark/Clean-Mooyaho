//
//  TextInputViewController.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - TextInputViewController

public final class TextInputViewController: BaseViewController, TextInputScene {
    
    let bottomSlideMenuView = BaseBottomSlideMenuView()
    let titleLabel = UILabel()
    let inputTextView = InputTextView()
    let charCountLabel = UILabel()
    let confirmButton = ConfirmButton(type: .system)
    
    let viewModel: TextInputViewModel
    
    public init(viewModel: TextInputViewModel) {
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

extension TextInputViewController {
    
    private func bind() {
        
        self.bottomSlideMenuView.bindKeyboardFrameChangesIfPossible()?
            .disposed(by: self.disposeBag)
        
        self.inputTextView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.textUpdated(text)
                self?.viewModel.updateInput(text: text)
            })
            .disposed(by: self.disposeBag)
        
        self.view.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirm()
            })
            .disposed(by: self.disposeBag)
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.close()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] enable in
                self?.confirmButton.isEnabled = enable
                self?.confirmButton.alpha = enable ? 1.0 : 0.6
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.inputTextView.textInputView.becomeFirstResponder()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func textUpdated(_ newText: String?) {
        self.inputTextView.placeHolderLabel.isHidden = newText?.isNotEmpty == true
        
        if let max = self.viewModel.textInputMode.maxCharCount {
            self.charCountLabel.text = "\(newText?.count ?? 0)/\(max)"
        } else {
            self.charCountLabel.text = nil
        }
    }
}

// MARK: - setup presenting

extension TextInputViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        bottomSlideMenuView.containerView.addSubview(inputTextView)
        inputTextView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        }
        inputTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        inputTextView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(charCountLabel)
        charCountLabel.autoLayout.active(with: inputTextView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -3)
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor, constant: 6)
        }
        charCountLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        charCountLabel.numberOfLines = 1
        
        bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        confirmButton.autoLayout.active {
            $0.topAnchor.constraint(equalTo: charCountLabel.bottomAnchor, constant: 30)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        let inputMode = self.viewModel.textInputMode
        
        self.uiContext.decorating.title(self.titleLabel)
        self.titleLabel.text = inputMode.title
        
        self.inputTextView.maxCharCount = inputMode.maxCharCount
        self.inputTextView.setupMultilineStyling(CGFloat(inputMode.defaultHeight ?? 200))
        self.inputTextView.placeHolderLabel.text = inputMode.placeHolder
        self.inputTextView.text = inputMode.startWith
        
        self.uiContext.decorating.placeHolder(self.inputTextView.placeHolderLabel)
        
        self.confirmButton.setupStyling()
    }
}
