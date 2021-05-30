//
//  KakaoService+OAuth2RepositoryImple.swift
//  MooyahoApp
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


// MARK: - KakaoOAuthErrors

public enum KakaoOAuthErrors: Error {
    case failToSignIn(_ reason: Error?)
}


// MARK: - KakaoOAuth2Repository signin

public protocol KakaoOAuth2Repository: AnyObject, OAuthRepository { }

public protocol KakaoOAuth2RepositoryDefImpleDependency {
    
    var kakaoOAuthRemote: KakaoOAuthRemote { get }
}

extension KakaoOAuth2Repository where Self: KakaoOAuth2RepositoryDefImpleDependency {
    
    public func requestSignIn() -> Maybe<OAuthCredential> {
        
        let requestKakaoSignIn = kakaoOAuthRemote.isKakaoTalkLoginAvailable()
            ? self.kakaoOAuthRemote.loginWithKakaoTalk()
            : self.kakaoOAuthRemote.loginWithKakaoAccount()
        
        let requestVerifyToken: (String) -> Maybe<String> = { [weak self] kakaoToken in
            guard let self = self else { return .empty() }
            logger.print(level: .debug, "kakao signin end, koAccessToken: \(kakaoToken)")
            return self.kakaoOAuthRemote.verifyKakaoAccessToken(kakaoToken)
        }
        
        let asOAuth2Credentail: (String) throws -> CustomTokenCredential = { customToken in
            logger.print(level: .debug, "custom token published: \(customToken)")
            return CustomTokenCredential(token: customToken)
        }
        
        return requestKakaoSignIn
            .flatMap(requestVerifyToken)
            .map(asOAuth2Credentail)
    }
}
