//
//  GoogleSignInButtonBuilder.swift
//  FirebaseService
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import GoogleSignIn


@MainActor
public struct GoogleSignInButtonBuilder {
    
    public init() { }
    
    public func makeButton() -> UIView {
        let button = GIDSignInButton()
        button.style = .wide
        return button
    }
}
