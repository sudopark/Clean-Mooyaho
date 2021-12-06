//
//  AuthRepository.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

public protocol AuthRepository {
    
    func fetchLastSignInAccountInfo() -> Maybe<(Auth, Member?)>
    
    func signInAnonymouslyForPrepareDataAcessPermission() -> Maybe<Auth>
    func requestSignIn(using secret: EmailBaseSecret) -> Maybe<SigninResult>
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult>
    
    func requestSignout() -> Maybe<Void>
    func requestWithdrawal() -> Maybe<Void>
}
