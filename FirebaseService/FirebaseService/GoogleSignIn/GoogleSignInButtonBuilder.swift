//
//  GoogleSignInButtonBuilder.swift
//  FirebaseService
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import GoogleSignIn


public struct GoogleSignInButtonBuilder {
    
    public init() { }
    
    public func makeButton() -> UIView {
        return GIDSignInButton()
    }
}
