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
    
    func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)>
    
    func requestSignIn(emailBaseSecret secret: EmailBaseSecret) -> Maybe<Member>
    
    func requestSocialSignIn() -> Maybe<Member>
    
    var currentAuth: Observable<Auth?> { get }
}


public final class AuthUsecaseImple: AuthUsecase {
    
    private let authRepository: AuthRepository
    private let oauth2Repository: OAuthRepository
    private let authInfoManager: AuthInfoManger
    private let sharedDataStroeService: SharedDataStoreService
    
    public init(authRepository: AuthRepository, socialAuthRepository: OAuthRepository,
                authInfoManager: AuthInfoManger, sharedDataStroeService: SharedDataStoreService) {
        self.authRepository = authRepository
        self.oauth2Repository = socialAuthRepository
        self.authInfoManager = authInfoManager
        self.sharedDataStroeService = sharedDataStroeService
    }
}


// MARK: - loadCurrentMember + signin

extension AuthUsecaseImple {
    
    public func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        let updateAccountInfos: (Auth, Member?) -> Void = { [weak self] auth, member in
            self?.updateAccountInfoOnSharedStore(auth, member: member)
        }
        
        return self.authRepository.fetchLastSignInAccountInfo()
            .do(onNext: updateAccountInfos)
            .map{ (auth: $0.0, member: $0.1) }
    }
    
    public func requestSignIn(emailBaseSecret secret: EmailBaseSecret) -> Maybe<Member> {
        
        let updateByResult: (SigninResult) -> Void = { [weak self] result in
            self?.updateAccountInfoOnSharedStore(result.auth, member: result.member)
        }
        return self.authRepository.requestSignIn(using: secret)
            .do(onNext: updateByResult)
            .map{ $0.member }
    }
    
    public func requestSocialSignIn() -> Maybe<Member> {
        
        let requestOAuth2signIn = self.oauth2Repository.requestSignIn()
        let thenSignInService: (OAuthCredential) -> Maybe<SigninResult> = { [weak self] credential in
            guard let self = self else { return .empty() }
            return self.authRepository.requestSignIn(using: credential)
        }
        let updateByResult: (SigninResult) -> Void = { [weak self] result in
            self?.updateAccountInfoOnSharedStore(result.auth, member: result.member)
        }
        
        return requestOAuth2signIn
            .flatMap(thenSignInService)
            .do(onNext: updateByResult)
            .map{ $0.member }
    }
    
    
    private func updateAccountInfoOnSharedStore(_ auth: Auth, member: Member?) {
        self.authInfoManager.updateAuth(auth)
        member.whenExists {
            self.sharedDataStroeService.update(SharedDataKeys.currentMember.rawValue, value: $0)
        }
    }
    
    public var currentAuth: Observable<Auth?> {
        return self.sharedDataStroeService
            .observe(SharedDataKeys.auth.rawValue)
    }
}
