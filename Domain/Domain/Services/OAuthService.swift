//
//  OAuthService.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol OAuthService {
    
    func requestSignIn() -> Maybe<OAuthCredential>
}
