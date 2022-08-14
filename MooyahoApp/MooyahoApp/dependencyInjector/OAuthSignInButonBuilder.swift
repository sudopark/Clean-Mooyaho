//
//  OAuthSignInButonBuilder.swift
//  MooyahoApp
//
//  Created by sudo.park on 2022/01/02.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import UIKit
import AuthenticationServices

import Domain
import CommonPresenting


extension UIControl: SignInButton { }

@MainActor
final class OAuthSignInButonBuilder: OAuthSignInButtonBuildable {
    
    private let googleSignInButtonBuilding: () -> SignInButton?
    
    init(googleSignInButtonBuilding: @escaping () -> SignInButton?) {
        self.googleSignInButtonBuilding = googleSignInButtonBuilding
    }
}


extension OAuthSignInButonBuilder {
    
    func makeButton(for type: OAuthServiceProviderType) -> SignInButton? {
        
        guard let definedTypes = type as? OAuthServiceProviderTypes else { return nil }
        switch definedTypes {
        case .kakao:
            let button = UIButton()
            button.setImage(UIImage(named: "kakao_login_large_wide"), for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.autoLayout.active {
                $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 3.18/21.27)
            }
            return button
            
        case .apple:
            let button = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
            return button
            
        case .google:
            return self.googleSignInButtonBuilding()
        }
    }
}
