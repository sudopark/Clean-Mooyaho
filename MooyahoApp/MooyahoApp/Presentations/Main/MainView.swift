//
//  MainView.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - CustomNavigationBar

final class CustomNavigationBar: BaseUIView, Presenting {
    
    let backButton = UIButton()
    let titleLabel = UILabel()
    let profileView = IntegratedImageView()
    
    func setupLayout() {
        
        self.addSubview(backButton)
        backButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.addSubview(profileView)
        profileView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 36)
            $0.heightAnchor.constraint(equalToConstant: 36)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        profileView.setupLayout()
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: self.profileView.leadingAnchor, constant: -16)
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
        
        self.profileView.setupStyling()
        self.profileView.layer.cornerRadius = 18
        self.profileView.clipsToBounds = true
        self.profileView.backgroundColor = .white
    }
}

final class MainView: BaseUIView {
    
    let customNavigationBar = CustomNavigationBar()
    
    let mainContainerView = UIView()
    let bottomSlideContainerView = UIView()
    var bottomSlideBottomOffsetConstraint: NSLayoutConstraint!
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
    }
    
    
    func setupStyling() {
        
        self.customNavigationBar.setupStyling()
        
        self.mainContainerView.backgroundColor = self.uiContext.colors.raw.clear
        
        self.bottomSlideContainerView.backgroundColor = self.uiContext.colors.appBackground
        self.bottomSlideContainerView.layer.cornerRadius = 10
        self.bottomSlideContainerView.clipsToBounds = true
        
    }
}
