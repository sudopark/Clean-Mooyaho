//
//  AuthUsecase.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

public protocol AuthUsecase {
    
    func loadCurrentMember() -> Maybe<Member?>
    
    func requestSocialSignIn() -> Maybe<Member>
}


public final class AuthUsecaseImple {
    
    private let authRepository: AuthRepository
    private let oauth2Repository: OAuthRepository
    
    public init(authRepository: AuthRepository, socialAuthRepository: OAuthRepository) {
        self.authRepository = authRepository
        self.oauth2Repository = socialAuthRepository
    }
}


// MARK: - loadCurrentMember + signin

extension AuthUsecaseImple {
    
    func loadCurrentMember() -> Maybe<Member?> {
        return self.authRepository.fetchLastSignInMember()
    }
    
    func requestSignIn(emailBaseSecret secret: EmailBaseSecret) -> Maybe<Member> {
        return self.authRepository.requestSignIn(using: secret)
    }
    
    func requestSocialSignIn() -> Maybe<Member> {
        
        let requestOAuth2signIn = self.oauth2Repository.requestSignIn()
        let thenSignInService: (OAuthCredential) -> Maybe<Member> = { [weak self] credential in
            guard let self = self else { return .empty() }
            return self.authRepository.requestSignIn(using: credential)
        }
        
        return requestOAuth2signIn
            .flatMap(thenSignInService)
    }
}
