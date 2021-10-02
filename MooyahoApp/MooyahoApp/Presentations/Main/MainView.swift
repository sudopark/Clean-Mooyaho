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

import CommonPresenting


// MARK: - CustomNavigationBar

final class CustomNavigationBar: BaseUIView, Presenting {
    
    let backButton = UIButton()
    let titleLabel = UILabel()
    let editButton = UIButton()
    
    func setupLayout() {
        
        self.addSubview(backButton)
        backButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.addSubview(editButton)
        editButton.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 16)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: self.editButton.leadingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.backButton.setImage(UIImage(named: "chevron.backward"), for: .normal)
        self.backButton.isHidden = true
        
        self.titleLabel.font = self.uiContext.fonts.get(15, weight: .medium)
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.isHidden = true
        
        self.editButton.setTitle("Edit".localized, for: .normal)
        self.editButton.setTitleColor(UIColor.systemBlue, for: .normal)
        self.editButton.titleLabel?.font = self.uiContext.fonts.get(14, weight: .regular)
    }
}


// MARK: - FloatingButtonButtonView

final class FloatingButtonButtonView: BaseUIView, Presenting {
    
    private let iconImageView = UIImageView()
    private let roundView = UIView()
    private let titleLabel = UILabel()
    fileprivate let backgroundButton = UIButton()
    
    func setupLayout() {
        
        self.addSubview(roundView)
        roundView.autoLayout.fill(self)
        
        self.addSubview(iconImageView)
        iconImageView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -8)
            $0.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 5)
        }
        
        self.addSubview(backgroundButton)
        backgroundButton.autoLayout.fill(self)
    }
    
    func setupStyling() {
        
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.4).cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.9
        
        self.roundView.layer.cornerRadius = 15
        self.roundView.clipsToBounds = true
        self.roundView.backgroundColor = UIColor.systemIndigo
        
        self.iconImageView.image = UIImage(named: "plus")
        self.iconImageView.tintColor = .white
        
        self.titleLabel.font = self.uiContext.fonts.get(16, weight: .bold)
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.text = "Add a item".localized
    }
}

extension Reactive where Base == FloatingButtonButtonView {
    
    func throttleTap() -> Observable<Void> {
        return base.backgroundButton.rx.tap.throttle(.milliseconds(500), scheduler: MainScheduler.instance)
    }
}


// MARK: - MainView

final class MainView: BaseUIView {
    
    let customNavigationBar = CustomNavigationBar()
    
    let mainContainerView = UIView()
    let bottomSlideContainerView = UIView()
    let bottomSearchBarView = SingleLineInputView()
    let profileImageView = IntegratedImageView()
    let bottomContentContainerView = UIView()
    let floatingBottomButtonContainerView = FloatingButtonButtonView()
    var bottomSlideBottomOffsetConstraint: NSLayoutConstraint!
    var bottomSliderSearbarTrailingConstraint: NSLayoutConstraint!
}


extension MainView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(customNavigationBar)
        customNavigationBar.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 44)
        }
        customNavigationBar.setupLayout()
        
        self.addSubview(mainContainerView)
        mainContainerView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: customNavigationBar.bottomAnchor)
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
            .topAnchor.constraint(equalTo: self.bottomAnchor, constant: -80)
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
        
        bottomSliderSearbarTrailingConstraint = bottomSearchBarView.trailingAnchor
            .constraint(equalTo: bottomSlideContainerView.trailingAnchor, constant: -16 - 36 - 12)
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
        }
        floatingBottomButtonContainerView.setupLayout()
    }
    
    
    func setupStyling() {
        
        self.customNavigationBar.setupStyling()
        self.customNavigationBar.editButton.isHidden = true
        
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
        
        self.floatingBottomButtonContainerView.setupStyling()
    }
}
