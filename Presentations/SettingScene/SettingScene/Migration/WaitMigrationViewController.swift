//
//  WaitMigrationViewController.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/11/07.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


// MARK: - WaitMigrationViewController

public final class WaitMigrationViewController: BaseViewController, WaitMigrationScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let emojiLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let confirmButton = ConfirmButton()
    private let laterButton = UIButton()
    
    let viewModel: WaitMigrationViewModel
    
    public init(viewModel: WaitMigrationViewModel) {
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

extension WaitMigrationViewController {
    
    private func bind() {
        
        self.viewModel.migrationProcessAndResult
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] newValue in
                self?.update(by: newValue)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.message
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] pair in
                self?.titleLabel.text = pair.title
                self?.descriptionLabel.text = pair.description
            })
            .disposed(by: self.disposeBag)
        
        self.laterButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.doMigrationLater()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmMigrationFinished()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidAppear.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.startMigration()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func update(by processAndResult: MigrationProcessAndResult) {
        switch processAndResult {
        case .migrating:
            self.emojiLabel.text = "🚀"
            self.startWaitAnimation()
            
        case .finished:
            self.stopWaitAnimation()
            self.emojiLabel.text = "🎉"
            self.laterButton.isHidden = true
            self.confirmButton.isHidden = false
            
        case .fail:
            self.stopWaitAnimation()
            self.emojiLabel.text = "😓"
            
        case .finishWithNotStarted:
            self.stopWaitAnimation()
            self.emojiLabel.text = "👍"
            self.laterButton.isHidden = true
            self.confirmButton.isHidden = false
        }
    }
    
    private func startWaitAnimation() {
        
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = NSNumber(value: -0.1)
        rotation.toValue = NSNumber(value: Double.pi * -0.15)
        rotation.duration = 0.1
        rotation.autoreverses = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.emojiLabel.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private func stopWaitAnimation() {
        self.emojiLabel.layer.removeAllAnimations()
        self.emojiLabel.transform = .identity
    }
}

// MARK: - setup presenting

extension WaitMigrationViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        self.bottomSlideMenuView.containerView.addSubview(emojiLabel)
        emojiLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -20)
            $0.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 8)
        }
        emojiLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.bottomSlideMenuView.containerView.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        }
        
        self.bottomSlideMenuView.containerView.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20)
        }
        
        self.bottomSlideMenuView.containerView.addSubview(laterButton)
        laterButton.autoLayout.active(with: self.bottomSlideMenuView.containerView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: confirmButton.topAnchor)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader(_:)
            |> \.text .~ pure("Wait for data migration".localized)
            |> \.textAlignment .~ .center
        
        _ = self.emojiLabel
            |> self.uiContext.decorating.smallHeader(_:)
            |> \.text .~ "🚀"
        
        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemTitle
            |> \.text .~ pure("Your locally stored data is being uploaded to cloud storage.\nPlease wait until the operation is completed.".localized)
            |> \.numberOfLines .~ 0
            |> \.textAlignment .~ .center
            |> \.textColor .~ self.uiContext.colors.descriptionText
        
        self.confirmButton.setupStyling()
        self.confirmButton.isHidden = true
        
        self.laterButton.setTitleColor(self.uiContext.colors.buttonBlue, for: .normal)
        self.laterButton.setTitle("Or do it latter >".localized, for: .normal)
        self.laterButton.titleLabel?.font = self.uiContext.fonts.get(13.5, weight: .medium)
    }
}
