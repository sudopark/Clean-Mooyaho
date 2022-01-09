//
//  GoogleSignInService.swift
//  FirebaseService
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import RxSwift

import Domain
import GoogleSignIn


// MARK: - GoggleSignInService

public protocol GoggleSignInService: OAuthService, OAuthServiceProviderTypeRepresentable {
    
    func handleURLOrNot(_ url: URL) -> Bool
}


public final class GoggleSignInServiceImple: GoggleSignInService {
    
    public init() {}
    
    public var providerType: OAuthServiceProviderType {
        return OAuthServiceProviderTypes.google
    }
}

extension GoggleSignInServiceImple {
    
    public func requestSignIn() -> Maybe<Domain.OAuthCredential> {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return .error(AuthErrors.noFirebaseClientID)
        }
        return Maybe.create { [weak self] callback in
            guard let topViewController = self?.topViewController()
            else {
                callback(.completed)
                return Disposables.create()
            }
            
            let configure = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.signIn(with: configure, presenting: topViewController) { user, error in
                guard error == nil,
                      let authToken = user?.authentication,
                      let idToken = authToken.idToken
                else {
                    callback(.error(AuthErrors.oauth2Fail(error)))
                    return
                }
                
                let credential = GoogleAuthCredential(idToken: idToken, accessToken: authToken.accessToken)
                callback(.success(credential))
            }
            return Disposables.create()
        }
    }
    
    private func topViewController() -> UIViewController? {
        return UIApplication.shared.windows.first?.rootViewController?.topPresentedViewController()
    }
}

extension GoggleSignInServiceImple {
    
    public func handleURLOrNot(_ url: URL) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

private extension UIViewController {
    
    func topPresentedViewController() -> UIViewController {
        guard let presented = self.presentedViewController else {
            return self
        }
        return presented.topPresentedViewController()
    }
}
