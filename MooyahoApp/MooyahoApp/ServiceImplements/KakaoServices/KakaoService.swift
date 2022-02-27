//
//  KakaoService.swift
//  MooyahoApp
//
//  Created by ParkHyunsoo on 2021/05/01.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain

import KakaoSDKCommon
import KakaoSDKAuth


public protocol KakaoService: KakaoOAuth2Service, OAuthServiceProviderTypeRepresentable {
    
    func setupService()
    
    func canHandleURL(_ url: URL) -> Bool
    
    func handle(url: URL) -> Bool
}


public final class KakaoServiceImple: KakaoService, KakaoOAuth2ServiceDefImpleDependency {
    
    public var kakaoOAuthRemote: KakaoOAuthRemote
    
    public let providerType: OAuthServiceProviderType = OAuthServiceProviderTypes.kakao
    
    public init(remote: KakaoOAuthRemote) {
        self.kakaoOAuthRemote = remote
    }
    
    private func loadNativeAppkey() -> String? {
        return (Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APPKEY") as? String)?
            .replacingOccurrences(of: "kakao", with: "")
    }
    
    public func setupService() {
        guard let nativeKey = self.loadNativeAppkey() else { return }
        KakaoSDK.initSDK(appKey: nativeKey)
    }
    
    public func canHandleURL(_ url: URL) -> Bool {
        return AuthApi.isKakaoTalkLoginUrl(url)
    }
    
    public func handle(url: URL) -> Bool {
        return AuthController.handleOpenUrl(url: url)
    }
}
