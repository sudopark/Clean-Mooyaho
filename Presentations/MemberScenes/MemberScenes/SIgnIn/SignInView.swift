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


public class SignInView: BaseUIView {
    
    let guideView = UIView()
    let signInButtonContainerView = UIStackView()
}


extension SignInView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(signInButtonContainerView)
        signInButtonContainerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 40)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -40)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -16)
        }
        
        self.addSubview(guideView)
        guideView.autoLayout.active(with: self) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.leadingAnchor.constraint(greaterThanOrEqualTo: $1.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -16)
            $0.bottomAnchor.constraint(equalTo: signInButtonContainerView.topAnchor, constant: -16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 20)
            $0.widthAnchor.constraint(equalTo: $1.heightAnchor, multiplier: 1.33)
        }
    }
    
    public func setupStyling() {
        
        self.guideView.backgroundColor = .black
        
        self.signInButtonContainerView.axis = .vertical
        self.signInButtonContainerView.distribution = .fillEqually
    }
}
