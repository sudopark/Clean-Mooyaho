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
    
    func requestSocialSignIn(_ providerType: OAuthServiceProviderType) -> Maybe<Member>
    
    func requestSignout() -> Maybe<Auth>
    
    func requestWithdrawal() -> Maybe<Auth>
    
    var currentAuth: Observable<Auth?> { get }
    
    var signedOut: Observable<Auth> { get }
    
    var supportingOAuthServiceProviders: [OAuthServiceProviderType] { get }
}


public typealias OAuthServiceProvider = OAuthService & OAuthServiceProviderTypeRepresentable

public final class AuthUsecaseImple: AuthUsecase {
    
    private let authRepository: AuthRepository
    private let oathServiceProviders: [OAuthServiceProvider]
    private let authInfoManager: AuthInfoManger
    private let sharedDataStroeService: SharedDataStoreService
    private let searchReposiotry: IntegratedSearchReposiotry
    
    public init(authRepository: AuthRepository,
                oathServiceProviders: [OAuthServiceProvider],
                authInfoManager: AuthInfoManger,
                sharedDataStroeService: SharedDataStoreService,
                searchReposiotry: IntegratedSearchReposiotry) {
        
        self.authRepository = authRepository
        self.oathServiceProviders = oathServiceProviders
        self.authInfoManager = authInfoManager
        self.sharedDataStroeService = sharedDataStroeService
        self.searchReposiotry = searchReposiotry
    }
    
    private let signedoutAuth = PublishSubject<Auth>()
    private let disposeBag = DisposeBag()
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
            .do(afterNext: self.postSignInAction())
    }
    
    public func requestSocialSignIn(_ providerType: OAuthServiceProviderType) -> Maybe<Member> {
        
        guard let provider = self.oathServiceProviders.provider(providerType) else {
            return .error(ApplicationErrors.unsupportSignInProvider)
        }
        
        logger.print(level: .debug, "will signin, provider: \(provider.providerType.uniqueIdentifier)")
        
        let requestOAuth2signIn = provider.requestSignIn()
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
            .do(afterNext: self.postSignInAction())
    }
    
    public func requestSignout() -> Maybe<Auth> {
        let signout = self.authRepository.requestSignout()
        let thenPostAction: () -> Maybe<Auth> = { [weak self] in
            return self?.postSignoutAction() ?? .empty()
        }
        return signout
            .flatMap(thenPostAction)
    }
    
    public func requestWithdrawal() -> Maybe<Auth> {
        let withdrawal = self.authRepository.requestWithdrawal()
        let thenPostAction: () -> Maybe<Auth> = { [weak self] in
            return self?.postSignoutAction() ?? .empty()
        }
        return withdrawal
            .flatMap(thenPostAction)
    }
    
    private func postSignoutAction() -> Maybe<Auth> {
        self.sharedDataStroeService.flush()
        
        let thenNotifySignedOut: (Auth) -> Void = { [weak self] auth in
            self?.signedoutAuth.onNext(auth)
        }
        
        return self.authRepository.signInAnonymouslyForPrepareDataAcessPermission()
            .do(onNext: thenNotifySignedOut)
    }
    
    private func updateAccountInfoOnSharedStore(_ auth: Auth, member: Member?) {
        logger.print(level: .info, "current auth changed: \(auth) and member: \(String(describing: member))")
        self.authInfoManager.updateAuth(auth)
        guard let me = member else { return }
        self.sharedDataStroeService
            .update(Member.self, key: SharedDataKeys.currentMember.rawValue, value: me)
        self.sharedDataStroeService
            .update([String: Member].self, key: SharedDataKeys.memberMap.rawValue) { dict in
                return (dict ?? [:]).merging([me.uid: me], uniquingKeysWith: { $1 })
            }
    }
    
    private func postSignInAction() -> (Member) -> Void {
        return { [weak self] member in
            guard let self = self else { return }
            self.downloadSuggestableQueries(memberID: member.uid)
        }
    }
    
    private func downloadSuggestableQueries(memberID: String) {
        
        searchReposiotry.downloadAllSuggestableQueries(memberID: memberID)
            .subscribe(onSuccess: {
                logger.print(level: .goal, "all suggestable queries downloaded")
            })
            .disposed(by: self.disposeBag)
    }
    
    public var currentAuth: Observable<Auth?> {
        return self.sharedDataStroeService
            .observeWithCache(Auth.self, key: SharedDataKeys.auth.rawValue)
    }
    
    public var supportingOAuthServiceProviders: [OAuthServiceProviderType] {
        return self.oathServiceProviders.map{ $0.providerType }
    }
    
    public var signedOut: Observable<Auth> {
        return self.signedoutAuth
            .asObservable()
    }
}

private extension Array where Element == OAuthServiceProvider {
    
    func provider(_ providerType: OAuthServiceProviderType) -> OAuthServiceProvider? {
        return self.first(where: { $0.providerType.uniqueIdentifier == providerType.uniqueIdentifier })
    }
}
