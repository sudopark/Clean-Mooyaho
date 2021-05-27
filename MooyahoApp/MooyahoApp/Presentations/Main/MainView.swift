//
//  MainView.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import CommonPresenting



// MARK: - MainNavibarView

public final class MainNavibarView: BaseUIView, Presenting {
    
    public let titleLabel: UILabel = .init()
    public let profileImageView: UIImageView = .init()
    public let badgeView: UIView = .init()
    
    public func setupLayout() {
        
        self.addSubview(self.profileImageView)
        self.profileImageView.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 35)
            $0.heightAnchor.constraint(equalToConstant: 35)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        
        self.addSubview(self.badgeView)
        self.badgeView.autoLayout.active(with: self.profileImageView) {
            $0.widthAnchor.constraint(equalToConstant: 3)
            $0.heightAnchor.constraint(equalToConstant: 3)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 1.5)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 1.5)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout
            .active(with: self) {
                $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
                $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
                $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor, constant: 10)
            }.active(with: self.profileImageView) {
                $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.leadingAnchor, constant: -16)
            }
    }
    
    public func setupStyling() {
        
        self.backgroundColor = self.context.colors.appBackground
        
        self.titleLabel.textColor = self.context.colors.text
        
        self.profileImageView.backgroundColor = UIColor.black
        self.profileImageView.layer.cornerRadius = 17.5
        self.profileImageView.clipsToBounds = true
        
        self.badgeView.backgroundColor = self.context.colors.raw.red
        self.badgeView.layer.cornerRadius = 1.5
        self.badgeView.clipsToBounds = true
    }
}



public final class MainView: BaseUIView {
    
    public let navigationBarView = MainNavibarView()
    public let mapContainerView = UIView()
    public let bottomSlideContainerView = UIView()
    var bottomSlideBottomOffsetConstraint: NSLayoutConstraint!
}


extension MainView: Presenting {
    
    
    public func setupLayout() {
        
        self.addSubview(self.navigationBarView)
        self.navigationBarView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 44)
        }
        self.navigationBarView.setupLayout()
        
        self.addSubview(mapContainerView)
        mapContainerView.autoLayout.active(with: navigationBarView) {
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        mapContainerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -80)
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
    
    
    public func setupStyling() {
        self.backgroundColor = self.context.colors.appBackground
        
        self.navigationBarView.setupStyling()
        
        self.mapContainerView.backgroundColor = self.context.colors.raw.clear
        
        self.bottomSlideContainerView.backgroundColor = .red
    }
}
