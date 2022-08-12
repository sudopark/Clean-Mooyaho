//
//  RecoverAccountViewController.swift
//  MemberScenes
//
//  Created sudo.park on 2022/01/09.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import Domain
import CommonPresenting

// MARK: - RecoverAccountViewController

public final class RecoverAccountViewController: BaseViewController, RecoverAccountScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let borderView = UIView()
    private let thumbnailImageView = IntegratedImageView()
    private let nameLabel = UILabel()
    private let deactivateDateLabel = UILabel()
    private let descriptionTipsView = DescriptionTipsView()
    private let confirmButton = ConfirmButton()
    
    let viewModel: RecoverAccountViewModel
    
    public init(viewModel: RecoverAccountViewModel) {
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
    
    public func requestCloseScene() { }
}

// MARK: - bind

extension RecoverAccountViewController {
    
    private func bind() {
        
        self.viewModel.memberInfo
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] memberInfo in
                self?.updateMemberInfo(memberInfo)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.deactivateDateText
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] text in
                self?.updateDeactivateText(text)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isRecovering
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isRecovering in
                self?.confirmButton.updateIsLoading(isRecovering)
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmRecover()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateMemberInfo(_ memerInfo: MemberInfo) {
        self.thumbnailImageView.cancelSetupImage()
        self.thumbnailImageView.setupImage(using: memerInfo.thumbNail ?? Member.memberDefaultEmoji,
                                           resize: .init(width: 75, height: 75))
        self.nameLabel.text = memerInfo.name
    }
    
    private func updateDeactivateText(_ text: String) {
        self.deactivateDateLabel.text = text
    }
}

// MARK: - setup presenting

extension RecoverAccountViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        self.bottomSlideMenuView.containerView.addSubview(borderView)
        borderView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.widthAnchor.constraint(equalToConstant: 75)
            $0.heightAnchor.constraint(equalToConstant: 75)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
        }
        
        borderView.addSubview(thumbnailImageView)
        thumbnailImageView.autoLayout.fill(borderView, edges: .init(top: 1, left: 1, bottom: 1, right: 1))
        thumbnailImageView.setupLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: 8)
        }
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.bottomSlideMenuView.containerView.addSubview(deactivateDateLabel)
        deactivateDateLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        }
        
        self.bottomSlideMenuView.containerView.addSubview(descriptionTipsView)
        descriptionTipsView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: deactivateDateLabel.bottomAnchor, constant: 12)
        }
        descriptionTipsView.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionTipsView.setupLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.topAnchor.constraint(equalTo: descriptionTipsView.bottomAnchor, constant: 25)
        }
        confirmButton.setupLayout()
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> { self.uiContext.decorating.smallHeader($0) }
            |> \.text .~ "Welcome back!"
            |> \.textAlignment .~ .center
        
        self.thumbnailImageView.setupStyling()
        self.thumbnailImageView.backgroundColor = self.uiContext.colors.thumbnailBackground
        self.thumbnailImageView.layer.cornerRadius = 36.5
        self.thumbnailImageView.clipsToBounds = true
        
        self.borderView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.borderView.layer.cornerRadius = 37.5
        self.borderView.clipsToBounds = true
        
        _ = self.nameLabel
            |> { self.uiContext.decorating.listItemTitle($0) }
            |> \.numberOfLines .~ 0
            |> \.font .~ self.uiContext.fonts.get(16, weight: .medium)
            |> \.textAlignment .~ .center
        
        _ = self.deactivateDateLabel
            |> { self.uiContext.decorating.listItemDescription($0) }
            |> \.textAlignment .~ .center
        
        let explains = "recover_account_descriptions".localized.components(separatedBy: "\n")
        self.descriptionTipsView.setupStyling()
        self.descriptionTipsView.setupDescriptions(explains)
    
        self.confirmButton.setupStyling()
        self.confirmButton.title = "Recover account".localized
    }
}
