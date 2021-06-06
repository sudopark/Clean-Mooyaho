//
//  MainView.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting

final class MainView: BaseUIView {
    
    let topFloatingButtonContainerView = UIView()
    let profileView = IntegratedImageView()
    let currentPositionButton = UIButton(type: .system)
    let newHoorayButton = UIButton(type: .system)
    
    let mapContainerView = UIView()
    let bottomSlideContainerView = UIView()
    var bottomSlideBottomOffsetConstraint: NSLayoutConstraint!
}


extension MainView: Presenting {
    
    
    func setupLayout() {
            
        self.addSubview(mapContainerView)
        mapContainerView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.addSubview(topFloatingButtonContainerView)
        topFloatingButtonContainerView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        
        topFloatingButtonContainerView.addSubview(profileView)
        profileView.autoLayout.active(with: topFloatingButtonContainerView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.widthAnchor.constraint(equalToConstant: 36)
            $0.heightAnchor.constraint(equalToConstant: 36)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        profileView.setupLayout()
        
        topFloatingButtonContainerView.addSubview(currentPositionButton)
        currentPositionButton.autoLayout.active(with: profileView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.widthAnchor.constraint(equalToConstant: 36)
            $0.heightAnchor.constraint(equalToConstant: 36)
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: topFloatingButtonContainerView.bottomAnchor)
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
        
        self.addSubview(newHoorayButton)
        newHoorayButton.autoLayout.active(with: self) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.bottomAnchor.constraint(equalTo: bottomSlideContainerView.topAnchor, constant: -16)
        }
    }
    
    
    func setupStyling() {
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.profileView.setupStyling()
        self.profileView.layer.cornerRadius = 18
        self.profileView.clipsToBounds = true
        self.profileView.backgroundColor = .white
        
        self.currentPositionButton.backgroundColor = .black
        
        
        self.mapContainerView.backgroundColor = self.uiContext.colors.raw.clear
        
        self.bottomSlideContainerView.backgroundColor = self.uiContext.colors.appBackground
        self.bottomSlideContainerView.layer.cornerRadius = 10
        self.bottomSlideContainerView.clipsToBounds = true
        
        self.newHoorayButton.backgroundColor = .systemBlue
        self.newHoorayButton.setTitleColor(.white, for: .normal)
        self.newHoorayButton.setTitle("New", for: .normal)
        self.newHoorayButton.contentEdgeInsets = .init(top: 4, left: 8, bottom: 4, right: 8)
        self.newHoorayButton.layer.cornerRadius = 3
        self.newHoorayButton.clipsToBounds = true
    }
}
