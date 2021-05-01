//
//  ApplicationViewModel.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import FirebaseService

public final class ApplicationViewModel {
    
    private let firebaseService: FirebaseService
    private let kakaoService: KakaoService
    private let router: ApplicationRootRouting
    
    public init(firebaseService: FirebaseService,
                kakaoService: KakaoService,
                router: ApplicationRootRouting) {
        self.firebaseService = firebaseService
        self.kakaoService = kakaoService
        self.router = router
    }
    
}

// Interactor

extension ApplicationViewModel {
    
    func appDidLaunched() {
        
        defer {
            self.router.routeMain()
        }
        
        guard AppEnvironment.isTestBuild == false else { return }
        self.firebaseService.setupService()
        self.kakaoService.setupService()
    }
}

// Prenseter

extension ApplicationViewModel {
    
}
