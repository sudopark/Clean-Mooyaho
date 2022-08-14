//
//  StopShareCollectionViewController.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/16.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import Domain
import CommonPresenting

// MARK: - StopShareCollectionViewController

public final class StopShareCollectionViewController: BaseViewController, StopShareCollectionScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let collectionInfoView = CollectionInfoView()
    private let showFindMemberView = UIView()
    private let sharedMemberCountLabel = UILabel()
    private let findDiscolureIconView = UIImageView()
    private let stopShareButton = ConfirmButton()
    
    let viewModel: StopShareCollectionViewModel
    
    public init(viewModel: StopShareCollectionViewModel) {
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
        self.viewModel.refresh()
    }
    
    public func requestCloseScene() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - bind

extension StopShareCollectionViewController {
    
    private func bind() {
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.requestCloseScene()
            })
            .disposed(by: self.disposeBag)
        
        self.collectionInfoView.rx.throttleTap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.openShare()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.sharedMemberCount
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] count in
                self?.updateSharedMembers(by: count)
            })
            .disposed(by: self.disposeBag)
        
        let findTrigger = Observable.merge(
            self.sharedMemberCountLabel.rx.addTapgestureRecognizer(),
            self.findDiscolureIconView.rx.addTapgestureRecognizer()
        )
        findTrigger
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.findWhoSharedThieList()
            })
            .disposed(by: self.disposeBag)
        
        self.stopShareButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.requestStopShare()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isStopSharing
            .asDriver(onErrorDriveWith: .never())
            .drive(self.stopShareButton.rx.isLoading)
            .disposed(by: self.disposeBag)
        
        self.viewModel.collectionTitle
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] title in
                self?.collectionInfoView.setupView(title)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateSharedMembers(by count: Int) {
        let message = count > 0
            ? "This reading list was shared with %d user(s).".localized(with: count)
            : "It hasn't been shared with anyone yet.".localized
        self.sharedMemberCountLabel.isHidden = false
        self.sharedMemberCountLabel.text = message
        self.sharedMemberCountLabel.textColor = count > 0
            ? self.uiContext.colors.buttonBlue
            : self.uiContext.colors.descriptionText
        self.sharedMemberCountLabel.isUserInteractionEnabled = count > 0
        self.findDiscolureIconView.isHidden = count <= 0
    }
}

// MARK: - setup presenting

extension StopShareCollectionViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        bottomSlideMenuView.containerView.addSubview(self.stopShareButton)
        stopShareButton.setupLayout(bottomSlideMenuView.containerView)
        
        self.bottomSlideMenuView.containerView.addSubview(showFindMemberView)
        showFindMemberView.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: stopShareButton.topAnchor, constant: -20)
        }
        
        showFindMemberView.addSubview(findDiscolureIconView)
        findDiscolureIconView.autoLayout.active(with: showFindMemberView) {
            $0.widthAnchor.constraint(equalToConstant: 8)
            $0.heightAnchor.constraint(equalToConstant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        showFindMemberView.addSubview(sharedMemberCountLabel)
        sharedMemberCountLabel.autoLayout.active(with: showFindMemberView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: findDiscolureIconView.leadingAnchor, constant: -4)
        }
        
        self.bottomSlideMenuView.containerView.addSubview(collectionInfoView)
        collectionInfoView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: showFindMemberView.topAnchor, constant: -16)
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
        
        _ = self.titleLabel
            |> { self.uiContext.decorating.smallHeader($0) }
            |> \.text .~ pure("Sharing Reading List".localized)
        
        self.collectionInfoView.setupStyling()
        self.collectionInfoView.actionButton.setImage(UIImage(systemName: "square.and.arrow.up.fill"), for: .normal)
        
        _ = self.sharedMemberCountLabel
            |> { self.uiContext.decorating.listItemAccentText($0) }
            |> \.font .~ self.uiContext.fonts.get(15, weight: .regular)
            |> \.numberOfLines .~ 1
            |> \.isHidden .~ true
        
        self.findDiscolureIconView.image = UIImage(systemName: "chevron.right")
        self.findDiscolureIconView.contentMode = .scaleAspectFit
        self.findDiscolureIconView.tintColor = self.uiContext.colors.buttonBlue
        self.findDiscolureIconView.isHidden = true
        self.sharedMemberCountLabel.text = "Find who watch this reading list".localized
        
        self.stopShareButton.setupStyling()
        self.stopShareButton.title = "Stop sharing".localized
    }
}


// MARK: - CollectionInfoView

final class CollectionInfoView: BaseUIView, Presenting {
    
    let collectionNameLabel = UILabel()
    let actionButton = UIButton(type: .system)
    
    func setupView(_ title: String) {
        self.collectionNameLabel.text = title
    }
}

extension Reactive where Base == CollectionInfoView {
    
    @MainActor
    var throttleTap: Observable<Void> {
        let viewtap = base.rx.addTapgestureRecognizer()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in }
        return Observable.merge(viewtap, base.actionButton.rx.throttleTap())
    }
}

extension CollectionInfoView {
    
    func setupLayout() {
        self.addSubview(collectionNameLabel)
        collectionNameLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
        }
        
        self.addSubview(actionButton)
        actionButton.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 20)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor)
            collectionNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: actionButton.leadingAnchor, constant: -4)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
    }
    
    func setupStyling() {
        
        _ = self.collectionNameLabel
            |> { self.uiContext.decorating.listItemTitle($0) }
            |> \.font .~ self.uiContext.fonts.get(15, weight: .medium)
            |> \.numberOfLines .~ 1
        
        self.actionButton.tintColor = self.uiContext.colors.buttonBlue
        self.actionButton.contentMode = .scaleAspectFit
    }
}
