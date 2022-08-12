//
//  OAuthSignInButtonBuildable.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import Domain

@MainActor
public protocol SignInButton: UIView {
    
    func updateAppearance(by isDarkMode: Bool)
}

extension SignInButton {
    
    public func updateAppearance(by isDarkMode: Bool) { }
}

public protocol OAuthSignInButtonBuildable {
    
    func makeButton(for type: OAuthServiceProviderType) -> SignInButton?
}
