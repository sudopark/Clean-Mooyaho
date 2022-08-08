//
//  GoogleSignInService.swift
//  FirebaseService
//
//  Created by sudo.park on 2022/01/02.
//

import UIKit

import RxSwift
import RxSwiftDoNotation

import Domain
import GoogleSignIn


// MARK: - GoggleSignInService

public protocol GoggleSignInService: OAuthService, OAuthServiceProviderTypeRepresentable {
    
    func handleURLOrNot(_ url: URL) -> Bool
}


public final class GoggleSignInServiceImple: GoggleSignInService, Sendable {
    
    public init() {}
    
    public var providerType: OAuthServiceProviderType {
        return OAuthServiceProviderTypes.google
    }
}

extension GoggleSignInServiceImple {
    
    public func requestSignIn() -> Maybe<Domain.OAuthCredential> {
        return Maybe<Domain.OAuthCredential>.create { [weak self] in
            guard let credential = try await self?.requestSignIn() else{
                throw AuthErrors.signInError(nil)
            }
            return credential
        }
    }
    
    private func requestSignIn() async throws -> Domain.OAuthCredential {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthErrors.noFirebaseClientID
        }
        
        guard let topViewController = await self.topViewController() else {
            throw AuthErrors.signInError(nil)
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let configure = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.signIn(with: configure, presenting: topViewController) { user, error in
                guard error == nil,
                      let authToken = user?.authentication,
                      let idToken = authToken.idToken
                else {
                    continuation.resume(throwing: AuthErrors.oauth2Fail(error))
                    return
                }
                
                let credential = GoogleAuthCredential(idToken: idToken, accessToken: authToken.accessToken)
                continuation.resume(returning: credential)
            }
        }
    }
    
    @MainActor
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
