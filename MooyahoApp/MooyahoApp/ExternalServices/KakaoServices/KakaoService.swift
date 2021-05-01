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


public protocol KakaoService: KakaoOAuth2Repository {
    
    func setupService()
}


public final class KakaoServiceImple: KakaoService {
    
    public init() {}
    
    private func loadNativeAppkey() -> String? {
        return (Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APPKEY") as? String)?
            .replacingOccurrences(of: "kakao", with: "")
    }
    
    public func setupService() {
        guard let nativeKey = self.loadNativeAppkey() else { return }
        KakaoSDKCommon.initSDK(appKey: nativeKey)
    }
}
