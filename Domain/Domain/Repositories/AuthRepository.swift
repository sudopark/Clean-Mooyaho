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
    
    func fetchLastSignInMember() -> Maybe<Member?>
    
    func requestSignIn(using secret: EmailBaseSecret) -> Maybe<Member>
    func requestSignIn(using credential: OAuthCredential) -> Maybe<Member>
}
