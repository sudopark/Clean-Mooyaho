//
//  MockAuthUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/05/25.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit

open class MockAuthUsecase: AuthUsecase, Mocking {
    
    
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
    
    open func requestSignout() -> Maybe<Auth> {
        return self.resolve(key: "requestSignout") ?? .empty()
    }
    
    public let auth: BehaviorSubject<Auth?> = .init(value: nil)
    open var currentAuth: Observable<Auth?> {
        return auth
    }
    
    public var supportingOAuthProviders = [OAuthServiceProviderType]()
    open var supportingOAuthServiceProviders: [OAuthServiceProviderType] {
        return self.supportingOAuthProviders
    }
    
    public var signedOut: Observable<Auth> {
        return .empty()
    }
}
