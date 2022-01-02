//
//  AppleLoginService.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit
import AuthenticationServices
import CryptoKit

import RxSwift

import Domain


final class AppleLoginService: NSObject, OAuthService, OAuthServiceProviderTypeRepresentable {
    
    private var handleResult: ((Result<String, Error>) -> Void)?
    
    var providerType: OAuthServiceProviderType {
        return OAuthServiceProviderTypes.apple
    }
}


enum AppleLoginError: Error {
    case notAppleIDCredential
    case unavailToSerializeIDToken
    
}

extension AppleLoginService {
    
    func requestSignIn() -> Maybe<OAuthCredential> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            
            let nonce = self.makeNonce()
            self.handleResult = { result in
                switch result {
                case let .success(token):
                    let credential = AppleAuthCredential(
                        provider: "apple.com",
                        idToken: token,
                        nonce: nonce
                    )
                    callback(.success(credential))
                    
                case let .failure(error):
                    callback(.error(error))
                }
            }
            self.requestAppleLogin(nonce)
            
            return Disposables.create()
        }
    }
    
    private func requestAppleLogin(_ nonce: String) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        request.nonce = nonce
            .data(using: .utf8)
            .map { SHA256.hash(data: $0) }
            .map { $0.map { String(format: "%02x", $0) }.joined() }
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}


extension AppleLoginService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first ?? UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        self.handleResult?(.failure(error))
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        else {
            self.handleResult?(.failure(AppleLoginError.notAppleIDCredential))
            return
        }
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8)
        else {
            self.handleResult?(.failure(AppleLoginError.unavailToSerializeIDToken))
            return
        }
        self.handleResult?(.success(idTokenString))
    }
 
    func makeNonce() -> String {
        let charset: [Character] =
              Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let makeRandIndexes: () -> Int = {
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
              fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return Int(random) % charset.count
        }
        
        let randIndexes = (0..<16).map { _ in }.map(makeRandIndexes)
        return randIndexes.map { charset[$0] }.map { "\($0)" }.joined()
    }
    
}
