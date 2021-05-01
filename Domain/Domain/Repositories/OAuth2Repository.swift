//
//  SocialAuthRepository.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol OAuth2Repository {
    
    func requestSignIn() -> Maybe<OAuth2Credential>
}
