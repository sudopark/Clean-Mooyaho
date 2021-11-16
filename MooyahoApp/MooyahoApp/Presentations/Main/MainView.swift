//
//  MainView.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - FloatingButtonButtonView

final class FloatingButtonButtonView: BaseUIView, Presenting {
    
    fileprivate let closeImageView = UIImageView()
    private let roundView = RoundShadowView()
    private let titleLabel = UILabel()
    private let addressLabel = UILabel()
    fileprivate let backgroundButton = UIButton()
    
    func showButton(with addresss: String) {
        
        self.addressLabel.text = addresss
        self.roundView.updateLayer()
        
        self.isHidden = false
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 0.5, y: 1.0)
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .overrideInheritedCurve, animations: { [weak self] in
            self?.alpha = 1.0
            self?.transform = .identity
        })
    }
    
    func hideButton() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .overrideInheritedCurve, animations: { [weak self] in
            self?.alpha = 0.0
            self?.transform = CGAffineTransform(scaleX: 0.1, y: 1.0)
        }, completion: { [weak self] _ in
            self?.isHidden = true
        })
    }
    
    func setupLayout() {
        
        self.addSubview(roundView)
        roundView.autoLayout.fill(self)
        
        self.addSubview(closeImageView)
        closeImageView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        let containerView = UIView()
        self.addSubview(containerView)
        containerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -12)
        }
        
        containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: containerView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        
        containerView.addSubview(addressLabel)
        addressLabel.autoLayout.active(with: containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)
        }
        
        self.addSubview(backgroundButton)
        backgroundButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: closeImageView.leadingAnchor, constant: -12)
        }
    }
    
    func setupStyling() {
        
        self.roundView.cornerRadius = 15
        self.roundView.fillColor = self.uiContext.colors.appBackground
        self.roundView.shadowOpacity = 0.9
        
        self.closeImageView.image = UIImage(systemName: "xmark")
        self.closeImageView.tintColor = self.uiContext.colors.text
        self.closeImageView.contentMode = .scaleAspectFit
        
        self.titleLabel.font = self.uiContext.fonts.get(15, weight: .medium)
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.textAlignment = .center
        self.titleLabel.text = "Add item form clipboard".localized
        
        self.addressLabel.font = self.uiContext.fonts.get(12, weight: .regular)
        self.addressLabel.textColor = self.uiContext.colors.secondaryTitle
        self.addressLabel.textAlignment = .center
        self.addressLabel.numberOfLines = 1
    }
}

extension Reactive where Base == FloatingButtonButtonView {
    
    func throttleTap() -> Observable<Void> {
        return base.backgroundButton.rx.tap.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
    }
    
    func closeTap() -> Observable<Void> {
        return base.closeImageView.rx.addTapgestureRecognizer()
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { _ in }
    }
}


// MARK: - MainView

final class MainView: BaseUIView {
    
    let mainContainerView = UIView()
    let bottomSlideContainerView = UIView()
    
    let profileImageView = IntegratedImageView()
    let bottomContentContainerView = UIView()
    let shrinkButton = RoundImageButton()
    
    let floatingBottomButtonContainerView = FloatingButtonButtonView()
    var bottomSlideBottomOffsetConstraint: NSLayoutConstraint!
    var bottomSliderSearbarTrailingConstraint: NSLayoutConstraint!
    
    // toolview for my collections
    let bottomSearchBarView = SingleLineInputView()
    let addItemButton = RoundImageButton()
    let shareButton = RoundImageButton()
    
    // toolview for shared collection
    let sharedCoverView = UIView()
    let sharedRootCollectionView = SharedRootCollectionInfoView()
    let favoriteButton = RoundImageButton()
    let exitButton = RoundImageButton()
    
    
    private var searchBarShrinkTrailing: CGFloat {
//        -16 - 36 - 12 - 32 - 10 - 10 - 32
        let profileSpacing: CGFloat = 16 + 36 + 12
        let buttonSpacing: CGFloat = 32 + 10
        return profileSpacing + buttonSpacing * 3
    }
    
    private var searchBarExpandTrailing: CGFloat {
        return 16
    }
    
    func updateBottomToolbar(by root: CollectionRoot) {
        switch root {
        case .myCollections:
            self.sharedCoverView.isHidden = true
            
        case .sharedCollection(let sharedReadCollection):
            self.sharedCoverView.isHidden = true
            self.sharedRootCollectionView.setup(sharedCollection: sharedReadCollection)
        }
    }
    
    func updateShareStatus(_ newValue: ActivationStatus) {
        switch newValue {
        case .unavail:
            self.shareButton.backgroundColor = self.uiContext.colors.raw.lightGray
            self.shareButton.isEnabled = false
             
        case .activable:
            self.shareButton.backgroundColor = self.uiContext.colors.raw.lightGray
            self.shareButton.isEnabled = true
            
        case .activated:
            self.shareButton.backgroundColor = UIColor.systemPink
            self.shareButton.isEnabled = true
            
        }
    }
}


extension MainView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(mainContainerView)
        mainContainerView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        self.addSubview(bottomSlideContainerView)
        bottomSlideContainerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor, constant: 0)
        }
        self.bottomSlideBottomOffsetConstraint = self.bottomSlideContainerView
            .topAnchor.constraint(equalTo: self.bottomAnchor, constant: -60)
        NSLayoutConstraint.activate([self.bottomSlideBottomOffsetConstraint])
        
        self.bottomSlideContainerView.addSubview(bottomSearchBarView)
        bottomSearchBarView.autoLayout.active(with: bottomSlideContainerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
        }
        bottomSearchBarView.setupLayout()
        
        self.bottomSlideContainerView.addSubview(profileImageView)
        profileImageView.autoLayout.active(with: bottomSlideContainerView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.widthAnchor.constraint(equalToConstant: 36)
            $0.heightAnchor.constraint(equalToConstant: 36)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            bottomSearchBarView.centerYAnchor.constraint(equalTo: $0.centerYAnchor)
        }
        profileImageView.setupLayout()
        
        self.bottomSlideContainerView.addSubview(addItemButton)
        addItemButton.autoLayout.active(with: profileImageView) {
            $0.widthAnchor.constraint(equalToConstant: 32)
            $0.heightAnchor.constraint(equalToConstant: 32)
            $0.trailingAnchor.constraint(equalTo: $1.leadingAnchor, constant: -10)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        addItemButton.setupLayout()
        
        self.bottomSlideContainerView.addSubview(favoriteButton)
        favoriteButton.autoLayout.active(with: addItemButton) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor)
        }
        favoriteButton.setupLayout()
        
        self.bottomSlideContainerView.addSubview(shrinkButton)
        shrinkButton.autoLayout.active(with: addItemButton) {
            $0.widthAnchor.constraint(equalToConstant: 32)
            $0.heightAnchor.constraint(equalToConstant: 32)
            $0.trailingAnchor.constraint(equalTo: $1.leadingAnchor, constant: -10)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        shrinkButton.setupLayout()
        
        self.bottomSlideContainerView.addSubview(shareButton)
        shareButton.autoLayout.active(with: shrinkButton) {
            $0.widthAnchor.constraint(equalToConstant: 32)
            $0.heightAnchor.constraint(equalToConstant: 32)
            $0.trailingAnchor.constraint(equalTo: $1.leadingAnchor, constant: -10)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        shareButton.setupLayout()

        let defaultTrailing: CGFloat = -self.searchBarShrinkTrailing
        bottomSliderSearbarTrailingConstraint = bottomSearchBarView.trailingAnchor
            .constraint(equalTo: bottomSlideContainerView.trailingAnchor, constant: defaultTrailing)
        bottomSliderSearbarTrailingConstraint.isActive = true
        
        bottomSlideContainerView.addSubview(bottomContentContainerView)
        bottomContentContainerView.autoLayout.active(with: bottomSlideContainerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.addSubview(floatingBottomButtonContainerView)
        floatingBottomButtonContainerView.autoLayout.active(with: bottomSlideContainerView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.topAnchor, constant: -8)
            $0.widthAnchor.constraint(lessThanOrEqualTo: self.widthAnchor, multiplier: 0.7)
        }
        floatingBottomButtonContainerView.setupLayout()
        
        bottomSlideContainerView.addSubview(sharedCoverView)
        sharedCoverView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: bottomSearchBarView.leadingAnchor)
            $0.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: shrinkButton.leadingAnchor, constant: -10)
        }
        
        sharedCoverView.addSubview(exitButton)
        exitButton.autoLayout.active(with: sharedCoverView) {
            $0.widthAnchor.constraint(equalToConstant: 32)
            $0.heightAnchor.constraint(equalToConstant: 32)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        exitButton.setupLayout()
        
        sharedCoverView.addSubview(sharedRootCollectionView)
        sharedRootCollectionView.autoLayout.active(with: sharedCoverView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: -5)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: exitButton.leadingAnchor, constant: -8)
        }
        sharedRootCollectionView.setupLayout()
    }
    
    
    func setupStyling() {
        
        self.mainContainerView.backgroundColor = self.uiContext.colors.raw.clear
        
        self.bottomSlideContainerView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.bottomSlideContainerView.layer.cornerRadius = 15
        self.bottomSlideContainerView.clipsToBounds = true
        
        self.bottomSearchBarView.layer.cornerRadius = 10
        self.bottomSearchBarView.clipsToBounds = true
        self.bottomSearchBarView.setupStyling()
        self.bottomSearchBarView.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.bottomSearchBarView.iconImageView.tintColor = UIColor.black.withAlphaComponent(0.1)
        self.bottomSearchBarView.placeHolderLabel.text = "Search collection or link"
        
        self.profileImageView.setupStyling()
        self.profileImageView.backgroundColor = self.uiContext.colors.hintText
        self.profileImageView.layer.cornerRadius = 18
        self.profileImageView.clipsToBounds = true
        
        self.addItemButton.setupButton("plus", color: self.uiContext.colors.buttonBlue)
        
        self.favoriteButton.setupButton("star", color: self.uiContext.colors.raw.lightGray)
        self.favoriteButton.isHidden = true
        
        self.shareButton.setupButton("square.and.arrow.up", color: self.uiContext.colors.raw.lightGray)
        self.shareButton.isEnabled = false
        
        self.shrinkButton.setupButton("arrow.down.forward.and.arrow.up.backward",
                                      color: self.uiContext.colors.raw.lightGray)
        
        
        self.sharedCoverView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.sharedCoverView.isHidden = true
        
        self.exitButton.setupButton("arrow.uturn.backward", color: self.uiContext.colors.raw.lightGray)
        
        self.sharedRootCollectionView.setupStyling()
        
        self.floatingBottomButtonContainerView.setupStyling()
        self.floatingBottomButtonContainerView.isHidden = true
    }
}


// MARK: - SharedRootCollectionInfoView

final class SharedRootCollectionInfoView: BaseUIView, Presenting {
    
    let collectionNameLabel = UILabel()
    let sharedLabel = UILabel()
    let ownerProfileImageView = IntegratedImageView()
    let ownerNameLabel = UILabel()
    
    func setup(sharedCollection: SharedReadCollection) {
        self.updateOwnerInfo(nil)
        self.collectionNameLabel.text = sharedCollection.name
    }
    
    func bindOwnerInfo(_ source: Observable<Member?>) -> Disposable {
        
        return source
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] member in
                self?.updateOwnerInfo(member)
            })
    }
    
    private func updateOwnerInfo(_ member: Member?) {
        self.ownerNameLabel.text = member?.nickName ?? "Unknown".localized
        self.ownerProfileImageView.cancelSetupImage()
        guard let icon = member?.icon else { return }
        self.ownerProfileImageView.setupImage(using: icon, resize: .init(width: 15, height: 15))
    }
}


extension SharedRootCollectionInfoView {
    
    func setupLayout() {
        self.addSubview(collectionNameLabel)
        collectionNameLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
        collectionNameLabel.setContentHuggingPriority(.required, for: .vertical)
        
        self.addSubview(ownerProfileImageView)
        ownerProfileImageView.autoLayout.active(with: self) {
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -6)
            $0.topAnchor.constraint(equalTo: collectionNameLabel.bottomAnchor, constant: 2)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        ownerProfileImageView.setupLayout()
        
        self.addSubview(sharedLabel)
        sharedLabel.autoLayout.active(with: ownerProfileImageView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12)
            $1.leadingAnchor.constraint(equalTo: $0.trailingAnchor, constant: 6)
        }
        sharedLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.addSubview(ownerNameLabel)
        ownerNameLabel.autoLayout.active(with: ownerProfileImageView) {
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 2)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -8)
        }
    }
    
    func setupStyling() {
        
        self.layer.borderColor = UIColor.systemTeal.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        self.backgroundColor = UIColor.from(hex: "#161B22")
        
        self.collectionNameLabel.font = self.uiContext.fonts.get(13.5, weight: .medium)
        self.collectionNameLabel.numberOfLines = 1
        self.collectionNameLabel.textColor = .white
        
        self.sharedLabel.font = self.uiContext.fonts.get(11, weight: .regular)
        self.sharedLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        self.sharedLabel.numberOfLines = 1
        self.sharedLabel.text = "shared by".localized
        
        self.ownerProfileImageView.layer.cornerRadius = 7.5
        self.ownerProfileImageView.clipsToBounds = true
        self.ownerProfileImageView.setupStyling()
        
        self.ownerNameLabel.numberOfLines = 1
        self.ownerNameLabel.font = self.uiContext.fonts.get(11.5, weight: .medium)
        self.ownerNameLabel.textColor = UIColor.white
    }
}


private extension RoundImageButton {
    
    func setupButton(_ image: String, color: UIColor, tintColor: UIColor = .white) {
        self.backgroundColor = color
        self.edge = .init(top: 6, left: 6, bottom: 6, right: 6)
        self.image = UIImage(systemName: image)
        self.tintColor = tintColor
        self.updateRadius(16)
        self.setupStyling()
    }
}
