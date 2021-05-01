//
//  KakaoService + OAuth2RepositoryImple.swift
//  MooyahoApp
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

import Domain


// MARK: - KakaoOAuthErrors

public enum KakaoOAuthErrors: Error {
    case failToSignIn(_ reason: Error?)
    case failToFetchUserInfo(_ reason: Error?)
    case invalidUserID
}


// MARK: - Kakao OAuth Credential and Result

public struct KakaoOAuthCredential: OAuth2Credential {
    
    private let serviceProviderKey = "KAKAO"
    public let uniqueIdentifier: String
    
    public init(userID: Int) {
        self.uniqueIdentifier = "\(serviceProviderKey)-\(userID)"
    }
}

public struct KakaoOAuthResult: OAuth2Result {
    
    public let credential: OAuth2Credential
    public let additionalInfo: OAuth2AdditionalUserInfo?
    
    public init(credential: KakaoOAuthCredential) {
        self.credential = credential
        self.additionalInfo = nil
    }
}


// MARK: - KakaoOAuth2Repository signin

public protocol KakaoOAuth2Repository: AnyObject, OAuth2Repository {
    
    func canHandleURL(_ url: URL) -> Bool
    
    func handle(url: URL) -> Bool
}

extension KakaoOAuth2Repository {
    
    public func canHandleURL(_ url: URL) -> Bool {
        return AuthApi.isKakaoTalkLoginUrl(url)
    }
    
    public func handle(url: URL) -> Bool {
        return AuthController.handleOpenUrl(url: url)
    }
    
    public func requestSignIn() -> Maybe<OAuth2Result> {
        
        let requestKakaoSignIn = UserApi.isKakaoTalkLoginAvailable()
            ? self.requestKakaoTalkSignIn() : self.requestKakaoAccountSignIn()
        
        let thenRequestUserInfo: () -> Maybe<User> = { [weak self] in
            return self?.requestKakaoUserInfo() ?? .empty()
        }
        let asOAuth2Result: (User) throws -> KakaoOAuthResult = { user in
            guard let userID = user.id else { throw KakaoOAuthErrors.invalidUserID }
            let credential = KakaoOAuthCredential(userID: Int(userID))
            return KakaoOAuthResult(credential: credential)
        }
        
        return requestKakaoSignIn
            .flatMap(thenRequestUserInfo)
            .map(asOAuth2Result)
    }
    
    private func requestKakaoTalkSignIn() -> Maybe<Void> {
        return Maybe.create { callback in
            UserApi.shared.loginWithKakaoTalk { token, error in
                guard error == nil, let _ = token else {
                    callback(.error(error ?? KakaoOAuthErrors.failToSignIn(nil)))
                    return
                }
                callback(.success(()))
            }
            return Disposables.create()
        }
    }
    
    private func requestKakaoAccountSignIn() -> Maybe<Void> {
        return Maybe.create { callback in
            UserApi.shared.loginWithKakaoAccount { token, error in
                guard error == nil, let _ = token else {
                    callback(.error(error ?? KakaoOAuthErrors.failToSignIn(nil)))
                    return
                }
                callback(.success(()))
            }
            return Disposables.create()
        }
    }
    
    private func requestKakaoUserInfo() -> Maybe<User> {
        return Maybe.create { callback in
            UserApi.shared.me { user, error in
                guard error == nil, let user = user else {
                    callback(.error(error ?? KakaoOAuthErrors.failToFetchUserInfo(error)))
                    return
                }
                callback(.success(user))
            }
            return Disposables.create()
        }
    }
}
