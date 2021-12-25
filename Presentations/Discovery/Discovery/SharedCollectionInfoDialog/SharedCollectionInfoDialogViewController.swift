//
//  SharedCollectionInfoDialogViewController.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/20.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting

// MARK: - SharedCollectionInfoDialogViewController

public final class SharedCollectionInfoDialogViewController: BaseViewController, SharedCollectionInfoDialogScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let collectionInfoView = CollectionInfoView()
    private let ownerInfoView = OwnerInfoView()
    private let removeButton = ConfirmButton()
    
    let viewModel: SharedCollectionInfoDialogViewModel
    
    public init(viewModel: SharedCollectionInfoDialogViewModel) {
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
        self.viewModel.requestClose()
    }
}

// MARK: - bind

extension SharedCollectionInfoDialogViewController {
    
    private func bind() {
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.requestCloseScene()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.collectionTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.collectionInfoView.setupView(title)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isRemoving
            .asDriver(onErrorDriveWith: .never())
            .drive(self.removeButton.rx.isLoading)
            .disposed(by: self.disposeBag)
        
        self.removeButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.removeFromSharedList()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.ownerInfo
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] member in
                self?.ownerInfoView.updateOwner(member)
            })
            .disposed(by: self.disposeBag)
        
        self.ownerInfoView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.showMemberProfile()
            })
            .disposed(by: self.disposeBag)
    }
}

// MARK: - setup presenting

extension SharedCollectionInfoDialogViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        bottomSlideMenuView.containerView.addSubview(self.removeButton)
        removeButton.setupLayout(bottomSlideMenuView.containerView)
        
        self.bottomSlideMenuView.containerView.addSubview(ownerInfoView)
        ownerInfoView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: removeButton.topAnchor, constant: -20)
        }
        ownerInfoView.setupLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(collectionInfoView)
        collectionInfoView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: ownerInfoView.topAnchor, constant: -8)
        }
        collectionInfoView.setupLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: self.collectionInfoView.topAnchor, constant: -16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        self.ownerInfoView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ pure("Shared Reading List".localized)
        
        self.collectionInfoView.setupStyling()
        self.collectionInfoView.actionButton.isHidden = true
        
        self.removeButton.setupStyling()
        self.removeButton.title = "Remove from shared list"
    }
}
