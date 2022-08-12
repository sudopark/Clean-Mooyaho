//
//  SignInView.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/29.
//

import UIKit

import RxSwift
import RxCocoa
import Prelude
import Optics

import CommonPresenting


public class SignInView: BaseUIView {
    
    let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    let guideView = GudieView()
    let signInButtonContainerView = UIStackView()
    let loadingView = FullScreenLoadingView()
    
    func appendSignInButton(_ button: SignInButton) {
        self.signInButtonContainerView.addArrangedSubview(button)
    }
    
    func updateIsActive(_ isActive: Bool) {
        self.signInButtonContainerView.arrangedSubviews
            .forEach {
                if let button = $0 as? UIButton {
                    button.isEnabled = isActive
                }
                $0.isUserInteractionEnabled = isActive
            }
    }
}


extension SignInView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(bottomSlideMenuView)
        bottomSlideMenuView.autoLayout.fill(self)
        bottomSlideMenuView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(guideView)
        guideView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.8)
        }
        guideView.setupLayout()
        
        bottomSlideMenuView.containerView.addSubview(signInButtonContainerView)
        signInButtonContainerView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 40)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -40)
            $0.topAnchor.constraint(equalTo: guideView.bottomAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        }
    }
    
    public func setupStyling() {
        
        bottomSlideMenuView.setupStyling()
        
        self.guideView.setupStyling()
        
        self.signInButtonContainerView.axis = .vertical
        self.signInButtonContainerView.distribution = .fillEqually
        self.signInButtonContainerView.setContentCompressionResistancePriority(.required, for: .vertical)
        self.signInButtonContainerView.spacing = 8
        
        self.loadingView.setupStyling()
    }
}


final class GudieView: BaseUIView {
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let tipsView = DescriptionTipsView()
    
    func startAnimation() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.fromValue = NSNumber(value: 0.2)
        rotation.toValue = NSNumber(value: Double.pi * -0.25)
        rotation.duration = 0.9
        rotation.autoreverses = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.emojiLabel.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func stopAnimation() {
        self.emojiLabel.layer.removeAllAnimations()
        self.emojiLabel.transform = .identity
    }
}

extension GudieView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(emojiLabel)
        emojiLabel.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
        }
        
        self.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.addSubview(tipsView)
        tipsView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        tipsView.setupLayout()
    }
    
    func setupStyling() {
        
        self.backgroundColor = .clear
        
        self.emojiLabel.font = UIFont.systemFont(ofSize: 30)
        self.emojiLabel.text = "🧐"
        
        _ = self.titleLabel
            |> { self.uiContext.decorating.listItemTitle($0) }
            |> \.text .~ pure("Log in to use the following services".localized)
            |> \.numberOfLines .~ 0
            |> \.textAlignment .~ .center
        
        let descriptions: [String] = [
            "You can back up your reading list and sync it across other ios devices\n(supported platforms will be expanded).".localized,
            "Share your organized reading list with others.\nOr you can read reading lists shared by others.".localized
        ]
        self.tipsView.setupStyling()
        self.tipsView.setupDescriptions(descriptions)
    }
}
