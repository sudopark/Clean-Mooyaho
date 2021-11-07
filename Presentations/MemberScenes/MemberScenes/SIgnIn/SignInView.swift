//
//  SignInView.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/29.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


protocol SignInButton: UIView { }

extension UIButton: SignInButton { }

public class SignInView: BaseUIView {
    
    let outsideTouchView = UIView()
    let containerView = UIView()
    let guideView = UIView()
    let signInButtonContainerView = UIStackView()
    
    func appendSignInButton(_ button: SignInButton) {
        self.signInButtonContainerView.addArrangedSubview(button)
        button.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.8)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 3.18/21.27)
        }
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
        
        self.addSubview(outsideTouchView)
        outsideTouchView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalTo: $1.heightAnchor, multiplier: 3/7)
        }
        
        self.addSubview(containerView)
        containerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: 10)
        }
        
        containerView.addSubview(guideView)
        guideView.autoLayout.active(with: containerView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor, multiplier: 0.8)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 3/4)
        }
        
        containerView.addSubview(signInButtonContainerView)
        signInButtonContainerView.autoLayout.active(with: containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 40)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -40)
            $0.topAnchor.constraint(equalTo: guideView.bottomAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        }
    }
    
    public func setupStyling() {
        
        self.outsideTouchView.backgroundColor = .clear
        
        self.containerView.backgroundColor = self.uiContext.colors.appBackground
        self.containerView.layer.cornerRadius = 10
        self.containerView.clipsToBounds = true
        
        self.guideView.backgroundColor = .black
        
        self.signInButtonContainerView.axis = .vertical
        self.signInButtonContainerView.distribution = .fillEqually
        self.signInButtonContainerView.setContentCompressionResistancePriority(.required, for: .vertical)
    }
}
