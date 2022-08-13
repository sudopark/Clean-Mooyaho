//
//  LinkMemoViewController.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/24.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting

// MARK: - LinkMemoViewController

public final class LinkMemoViewController: BaseViewController, LinkMemoScene {
    
    let bottomSlideMenuView = BaseBottomSlideMenuView()
    let titleLabel = UILabel()
    let deleteButton = UIButton()
    let textView = InputTextView()
    let confirmButton = ConfirmButton()
    
    let viewModel: LinkMemoViewModel
    
    public init(viewModel: LinkMemoViewModel) {
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

extension LinkMemoViewController {
    
    private func bind() {
        self.bottomSlideMenuView.bindKeyboardFrameChangesIfPossible()?
            .disposed(by: self.disposeBag)
        
        viewModel.confirmSavable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.textView.text = self.viewModel.initialText
        self.textView.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.textUpdated(text)
                self?.viewModel.updateContent(text)
            })
            .disposed(by: self.disposeBag)
        
        self.deleteButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.deleteMemo()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSave()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func textUpdated(_ newText: String?) {
        self.textView.placeHolderLabel.isHidden = newText?.isNotEmpty == true
    }
}

// MARK: - setup presenting

extension LinkMemoViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self.view)
        bottomSlideMenuView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        bottomSlideMenuView.containerView.addSubview(deleteButton)
        deleteButton.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8)
        }
        
        bottomSlideMenuView.containerView.addSubview(textView)
        textView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        }
        textView.setupLayout()
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        confirmButton.autoLayout.active {
            $0.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
        |> { self.uiContext.decorating.smallHeader($0) }
        |> \.text .~ pure("Memo".localized)
        
        self.deleteButton.setTitle("Delete".localized, for: .normal)
        self.deleteButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        
        self.textView.setupMultilineStyling(300)
        self.textView.placeHolderLabel.text = "Enter a memo".localized
        self.textView.placeHolderLabel.decorate(self.uiContext.decorating.placeHolder)
        
        self.confirmButton.setupStyling()
    }
}
