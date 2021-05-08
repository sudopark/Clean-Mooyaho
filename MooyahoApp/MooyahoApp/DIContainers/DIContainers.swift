//
//  DIContainers.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import CommonPresenting

import DataStore
import FirebaseService


// MARK: - DIContainers

public final class DIContainers {
    
    public class Shared {
        
        fileprivate init() {}
        
        public let firebaseService: FirebaseService = FirebaseServiceImple(httpRemote: HttpRemoteImple())
        public let kakaoService: KakaoService = KakaoServiceImple()
    }
    
    public let shared: Shared = Shared()
}

extension DIContainers: EmptyBuilder { }


class HttpRemoteImple: HttpRemote { }
