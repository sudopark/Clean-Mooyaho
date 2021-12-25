//
//  EditCategoryAttrViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting

// MARK: - EditCategoryAttrViewController

public final class EditCategoryAttrViewController: BaseViewController, EditCategoryAttrScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let nameField = UITextField()
    private let underLineView = UIView()
    private let colorIconView = UIImageView()
    private let colorLabel = UILabel()
    private let colorPreviewView = UIView()
    private let colorSelectIndicatorView = UIImageView()
    private let colorSectionView = UIView()
    private let colorSectionUnderLineView = UIView()
    private let deleteIconImageView = UIImageView()
    private let deleteButton = UIButton()
    private let confirmButton = ConfirmButton()
    
    let viewModel: EditCategoryAttrViewModel
    
    public init(viewModel: EditCategoryAttrViewModel) {
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

extension EditCategoryAttrViewController {
    
    private func bind() {
        
        self.bindBottomSlideMenuView()
        
        self.nameField.text = self.viewModel.initialName
        self.nameField.rx.text.orEmpty
            .skip(1)
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.enter(name: text)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.selectedColorCode
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] code in
                self?.colorPreviewView.backgroundColor = UIColor.from(hex: code)
            })
            .disposed(by: self.disposeBag)
        
        self.colorSectionView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.selectNewColor()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isChangeSavable
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isEnable in
                self?.confirmButton.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
        
        self.deleteButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.delete()
            })
            .disposed(by: self.disposeBag)
            
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSaveChange()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.nameField.becomeFirstResponder()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension EditCategoryAttrViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        bottomSlideMenuView.containerView.addSubview(self.confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        
        bottomSlideMenuView.containerView.addSubview(deleteIconImageView)
        deleteIconImageView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 18)
            $0.heightAnchor.constraint(equalToConstant: 18)
            $0.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -40)
        }
        
        bottomSlideMenuView.containerView.addSubview(self.deleteButton)
        deleteButton.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: deleteIconImageView.trailingAnchor, constant: 8)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -20)
            $0.centerYAnchor.constraint(equalTo: deleteIconImageView.centerYAnchor)
        }
        
        bottomSlideMenuView.containerView.addSubview(colorSectionView)
        colorSectionView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -12)
        }
        
        colorSectionView.addSubview(colorSectionUnderLineView)
        colorSectionUnderLineView.autoLayout.active(with: colorSectionView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        colorSectionView.addSubview(colorPreviewView)
        colorPreviewView.autoLayout.active(with: colorSectionView) {
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
            $0.bottomAnchor.constraint(equalTo: colorSectionUnderLineView.topAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 16)
        }
        
        colorSectionView.addSubview(colorSelectIndicatorView)
        colorSelectIndicatorView.autoLayout.active(with: colorSectionView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.widthAnchor.constraint(equalToConstant: 8)
            $0.heightAnchor.constraint(equalToConstant: 22)
            $0.centerYAnchor.constraint(equalTo: colorPreviewView.centerYAnchor)
            colorPreviewView.trailingAnchor.constraint(equalTo: $0.leadingAnchor, constant: -12)
        }
        
        colorSectionView.addSubview(colorIconView)
        colorIconView.autoLayout.active(with: colorSectionView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 18)
            $0.heightAnchor.constraint(equalToConstant: 18)
            $0.centerYAnchor.constraint(equalTo: colorPreviewView.centerYAnchor)
        }
        
        colorSectionView.addSubview(colorLabel)
        colorLabel.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: colorIconView.trailingAnchor, constant: 8)
            $0.centerYAnchor.constraint(equalTo: colorPreviewView.centerYAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: colorPreviewView.leadingAnchor, constant: -8)
        }
        colorLabel.numberOfLines = 1
        
        bottomSlideMenuView.containerView.addSubview(underLineView)
        underLineView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: colorSectionView.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
        }
        
        bottomSlideMenuView.containerView.addSubview(nameField)
        nameField.autoLayout.active(with: underLineView) {
            $0.bottomAnchor.constraint(equalTo: $1.topAnchor, constant: -6)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 20)
        }
        
        bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: self.nameField.topAnchor, constant: -16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Edit category"
        
        _ = self.nameField
            |> \.font .~ self.uiContext.fonts.get(14, weight: .regular)
            |> \.placeholder .~ "Enter a name"
            |> \.autocorrectionType .~ .no
            |> \.autocapitalizationType .~ .none
        
        self.underLineView.backgroundColor = self.uiContext.colors.lineColor
        
        self.colorSectionView.backgroundColor = .clear
        self.colorSectionView.isUserInteractionEnabled = true
        
        _ = self.colorIconView
            |> \.contentMode .~ .scaleAspectFit
            |> \.image .~ UIImage(systemName: "eyedropper")
            |> \.tintColor .~ self.uiContext.colors.secondaryTitle
        
        _ = self.colorLabel
            |> self.uiContext.decorating.listSectionTitle
            |> \.text .~ pure("change color".localized)
        
        self.colorPreviewView.layer.cornerRadius = 10
        self.colorPreviewView.clipsToBounds = true
        
        _ = self.colorSelectIndicatorView
            |> \.contentMode .~ .scaleAspectFit
            |> \.image .~ UIImage(systemName: "chevron.right")
            |> \.tintColor .~ self.uiContext.colors.hintText
        
        self.colorSectionUnderLineView.backgroundColor = self.uiContext.colors.lineColor
        
        _ = self.deleteIconImageView
            |> \.contentMode .~ .scaleAspectFit
            |> \.image .~ UIImage(systemName: "trash")
            |> \.tintColor .~ self.uiContext.colors.secondaryTitle
        
        self.deleteButton.setTitle("Delete", for: .normal)
        self.deleteButton.setTitleColor(self.uiContext.colors.secondaryTitle, for: .normal)
        self.deleteButton.titleLabel?.font = self.uiContext.fonts.get(13, weight: .bold)
        
        self.confirmButton.setupStyling()
        self.confirmButton.title = "Save change"
    }
}
