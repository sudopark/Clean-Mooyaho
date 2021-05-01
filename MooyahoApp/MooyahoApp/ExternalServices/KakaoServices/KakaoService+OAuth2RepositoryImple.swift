//
//  KakaoService+OAuth2RepositoryImple.swift
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


// MARK: - Kakao OAuth Credential

public struct KakaoOAuthCredential: OAuth2Credential {
    
    public let kakaoUserID: Int
    
    public init(userID: Int) {
        self.kakaoUserID = userID
    }
}


// MARK: - KakaoOAuth2Repository signin

public protocol KakaoOAuth2Repository: AnyObject, OAuth2Repository { }

extension KakaoOAuth2Repository {
    
    public func requestSignIn() -> Maybe<OAuth2Credential> {
        
        let requestKakaoSignIn = UserApi.isKakaoTalkLoginAvailable()
            ? self.requestKakaoTalkSignIn() : self.requestKakaoAccountSignIn()
        
        let thenRequestUserInfo: () -> Maybe<User> = { [weak self] in
            return self?.requestKakaoUserInfo() ?? .empty()
        }
        let asOAuth2Credentail: (User) throws -> KakaoOAuthCredential = { user in
            
            guard let userID = user.id else {
                throw KakaoOAuthErrors.invalidUserID
            }
            return KakaoOAuthCredential(userID: Int(userID))
        }
        
        return requestKakaoSignIn
            .flatMap(thenRequestUserInfo)
            .map(asOAuth2Credentail)
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
