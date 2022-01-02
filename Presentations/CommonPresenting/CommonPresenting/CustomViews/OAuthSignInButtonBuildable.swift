//
//  OAuthSignInButtonBuildable.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import Domain


public protocol SignInButton: UIView { }

public protocol OAuthSignInButtonBuildable {
    
    func makeButton(for type: OAuthServiceProviderType) -> SignInButton?
}
