//
//  AuthRemote.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain

public protocol AuthRemote {
    
    func requestSignIn(using credential: Credential) -> Maybe<Member>
}
