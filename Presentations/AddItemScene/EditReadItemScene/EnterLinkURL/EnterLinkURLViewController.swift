//
//  EnterLinkURLViewController.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import Domain

import CommonPresenting

// MARK: - EnterLinkURLViewController

public final class EnterLinkURLViewController: BaseViewController, EnterLinkURLScene {
    
    private let titleLabel = UILabel()
    private let textField = UITextField()
    private let underLineView = UIView()
    private let confirmButton = ConfirmButton()
    
    let viewModel: EnterLinkURLViewModel
    private var buttonConfirmBinding: Disposable?
    
    public init(viewModel: EnterLinkURLViewModel) {
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

extension EnterLinkURLViewController {
    
    private func bind() {
        
        self.viewModel.isConfirmable
            .asDriver(onErrorDriveWith: .never())
            .drive(self.confirmButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.textField.rx.text.orEmpty
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.enterURL(text)
            })
            .disposed(by: self.disposeBag)
        
        self.bindConfirmButton()
        
        self.rx.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                self?.bindConfirmButton()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindConfirmButton() {
        
        logger.print(level: .debug, "bind confirm button")
        
        self.buttonConfirmBinding?.dispose()
        self.buttonConfirmBinding = self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                logger.print(level: .debug, "move confirm called")
                self?.viewModel.confirmEnter()
            })
    }
}

// MARK: - setup presenting

extension EnterLinkURLViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        self.view.addSubview(textField)
        textField.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        }
        self.view.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.textField) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor, constant: 8)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
        
        self.view.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: underLineView.bottomAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        confirmButton.setupLayout()
    }
    
    public func setupStyling() {
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Add read link item"
        
        _ = self.textField
            |> \.font .~ self.uiContext.fonts.get(14, weight: .regular)
            |> \.placeholder .~ "Enter an url"
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        self.confirmButton.setupStyling()
        self.confirmButton.isEnabled = false
    }
}
