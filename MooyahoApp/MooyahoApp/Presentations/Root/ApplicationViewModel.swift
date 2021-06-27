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

import Domain
import FirebaseService


public protocol ApplicationViewModel {
    
    func appDidLaunched()
    func handleOpenURL(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]?) -> Bool
    func appDidBecomeActive()
    func appWillResignActive()
    func appDidEnterBackground()
    func appWillEnterForground()
    func appWillTerminate()
}


public final class ApplicationViewModelImple: ApplicationViewModel {
    
    
    private let applicationUsecase: ApplicationUsecase
    private let firebaseService: FirebaseService
    private let kakaoService: KakaoService
    private let router: ApplicationRootRouting
    
    public init(applicationUsecase: ApplicationUsecase,
                firebaseService: FirebaseService,
                kakaoService: KakaoService,
                router: ApplicationRootRouting) {
        self.applicationUsecase = applicationUsecase
        self.firebaseService = firebaseService
        self.kakaoService = kakaoService
        self.router = router
    }
    
    private let disposeBag = DisposeBag()
}

// Interactor

extension ApplicationViewModelImple {
    
    public func appDidLaunched() {
        
        defer {
            self.routeToMainAfterLoadLastAccountInfo()
        }
        
        guard AppEnvironment.isTestBuild == false else { return }
        self.firebaseService.setupService()
        self.kakaoService.setupService()
        
        self.applicationUsecase.updateApplicationActiveStatus(.launched)
    }
    
    private func routeToMainAfterLoadLastAccountInfo() {
        
        let routing: (Domain.Auth) -> Void = { [weak self] auth in
            self?.router.routeMain(auth: auth)
        }
        self.applicationUsecase.loadLastSignInAccountInfo()
            .map{ $0.auth }
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: routing)
            .disposed(by: self.disposeBag)
    }
    
    public func handleOpenURL(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]?) -> Bool {
        if self.kakaoService.canHandleURL(url) {
            return self.kakaoService.handle(url: url)
        }
        return false
    }
    
    public func appDidBecomeActive() { }
    
    public func appWillResignActive() { }
    
    public func appDidEnterBackground() {
        self.applicationUsecase.updateApplicationActiveStatus(.background)
    }
    
    public func appWillEnterForground() {
        self.applicationUsecase.updateApplicationActiveStatus(.forground)
    }
    
    public func appWillTerminate() {
        self.applicationUsecase.updateApplicationActiveStatus(.terminate)
    }
}

// Prenseter

extension ApplicationViewModelImple {
    
}
