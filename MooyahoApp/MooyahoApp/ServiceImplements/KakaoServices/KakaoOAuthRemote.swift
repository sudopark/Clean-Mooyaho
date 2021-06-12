//
//  KakaoOAuthRemote.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

import DataStore

// MARK: - KakaoOAuthRemote

public protocol KakaoOAuthRemote {
    
    func isKakaoTalkLoginAvailable() -> Bool
    func loginWithKakaoTalk() -> Maybe<String>
    func loginWithKakaoAccount() -> Maybe<String>
    func verifyKakaoAccessToken(_ token: String) -> Maybe<String>
}


public class KakaoOAuthRemoteImple: KakaoOAuthRemote {
    
    private let legacyAPIPath: String
    private let httpAPI: HttpAPI
    
    public init(path: String, api: HttpAPI) {
        self.legacyAPIPath = path
        self.httpAPI = api
    }
    
    public func isKakaoTalkLoginAvailable() -> Bool {
        return UserApi.isKakaoTalkLoginAvailable()
    }
    
    public func loginWithKakaoTalk() -> Maybe<String> {
        return Maybe.create { callback in
            UserApi.shared.loginWithKakaoTalk { token, error in
                guard error == nil, let accessToken = token?.accessToken else {
                    callback(.error(error ?? KakaoOAuthErrors.failToSignIn(nil)))
                    return
                }
                callback(.success(accessToken))
            }
            return Disposables.create()
        }
    }
    
    public func loginWithKakaoAccount() -> Maybe<String> {
        return Maybe.create { callback in
            UserApi.shared.loginWithKakaoAccount { token, error in
                guard error == nil, let accessToken = token?.accessToken else {
                    callback(.error(error ?? KakaoOAuthErrors.failToSignIn(nil)))
                    return
                }
                callback(.success(accessToken))
            }
            return Disposables.create()
        }
    }
    
    public func verifyKakaoAccessToken(_ token: String) -> Maybe<String> {
        
        let endPoint = LegacyAPIEndPoint(path: self.legacyAPIPath)
        let params: [String: Any] = ["token": token]
        
        return self.httpAPI
            .requestData(FirebaseCustomToken.self,
                         endpoint: endPoint, parameters: params)
            .map{ $0.customToken }
    }
    
    struct FirebaseCustomToken: Decodable {
        
        enum CodingKeys: String, CodingKey {
            case token
        }
        let customToken: String
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.customToken = try container.decode(String.self, forKey: .token)
        }
    }
}

