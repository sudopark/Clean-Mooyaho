//
//  StubAuthUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/05/25.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit

open class StubAuthUsecase: AuthUsecase, Stubbable {
    
    
    public init() {}
    
    open func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        self.verify(key: "loadLastSignInAccountInfo")
        return self.resolve(key: "loadLastSignInAccountInfo") ?? .empty()
    }
    
    open func requestSignIn(emailBaseSecret secret: EmailBaseSecret) -> Maybe<Member> {
        self.verify(key: "loadLastSignInAccountInfo")
        return self.resolve(key: "requestSignIn") ?? .empty()
    }
    
    open func requestSocialSignIn(_ providerType: OAuthServiceProviderType) -> Maybe<Member> {
        self.verify(key: "requestSocialSignIn")
        return self.resolve(key: "requestSocialSignIn") ?? .empty()
    }
    
    public let stubAuth: BehaviorSubject<Auth?> = .init(value: nil)
    open var currentAuth: Observable<Auth?> {
        return stubAuth
    }
    
    public var stubSupportingOAuthServiceProviders = [OAuthServiceProviderType]()
    open var supportingOAuthServiceProviders: [OAuthServiceProviderType] {
        return self.stubSupportingOAuthServiceProviders
    }
}
