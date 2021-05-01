//
//  Remote+Auth.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain

public protocol AuthRemote {
    
    func requestSignInAnonymously() -> Maybe<Void>
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<DataModels.Member>
    
    func requestSignIn(using credential: ReqParams.OAuthCredential) -> Maybe<DataModels.Member>
}
