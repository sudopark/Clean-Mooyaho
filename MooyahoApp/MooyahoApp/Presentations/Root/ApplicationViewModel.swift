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
    
    func apnsTokenUpdated(_ token: Data)
    func newPushMessageRecived(_ userInfo: [AnyHashable: Any])
}


public final class ApplicationViewModelImple: ApplicationViewModel {
    
    
    private let applicationUsecase: ApplicationUsecase
    private let shareCollectionHandleUsecase: SharedReadCollectionHandleUsecase
    private let firebaseService: FirebaseService
    private let fcmService: FCMService
    private let kakaoService: KakaoService
    private let router: ApplicationRootRouting
    
    public init(applicationUsecase: ApplicationUsecase,
                shareCollectionHandleUsecase: SharedReadCollectionHandleUsecase,
                firebaseService: FirebaseService,
                fcmService: FCMService,
                kakaoService: KakaoService,
                router: ApplicationRootRouting) {
        self.applicationUsecase = applicationUsecase
        self.shareCollectionHandleUsecase = shareCollectionHandleUsecase
        self.firebaseService = firebaseService
        self.fcmService = fcmService
        self.kakaoService = kakaoService
        self.router = router
        
        self.internalBinding()
    }
    
    private let disposeBag = DisposeBag()
    private var pendingShowRemindMessage: ReadRemindMessage?
    
    private func internalBinding() {
        
        self.fcmService.isNotificationGranted
            .distinctUntilChanged()
            .filter{ $0 == false }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.router.showNotificationAuthorizationNeedBanner()
            })
            .disposed(by: self.disposeBag)
        
        self.fcmService.currentFCMToken
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] token in
                self?.applicationUsecase.userFCMTokenUpdated(token)
            })
            .disposed(by: self.disposeBag)
        
        self.applicationUsecase
            .signedOut
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] auth in
                logger.print(level: .info, "user signedout")
                self?.router.routeMain(auth: auth)
            })
            .disposed(by: self.disposeBag)
        
        self.fcmService.receiveReadmindMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                self?.handleRemindMessage(message)
            })
            .disposed(by: self.disposeBag)
    }
}

// Interactor

extension ApplicationViewModelImple {
    
    public func appDidLaunched() {
        
        defer {
            self.routeToMainAfterLoadLastAccountInfo()
        }
        
        guard AppEnvironment.isTestBuild == false else { return }
        self.firebaseService.setupService()
        self.fcmService.setupFCMService()
        self.kakaoService.setupService()
        
        self.applicationUsecase.updateApplicationActiveStatus(.launched)
    }
    
    private func routeToMainAfterLoadLastAccountInfo() {
        
        let routing: (Domain.Auth) -> Void = { [weak self] auth in
            self?.router.routeMain(auth: auth)
            self?.showDetailIfNeed()
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
        if self.shareCollectionHandleUsecase.canHandleURL(url) {
            self.handleSharedCollection(url: url)
            return true
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
    
    public func apnsTokenUpdated(_ token: Data) {
        self.fcmService.apnsTokenUpdated(token)
    }
    
    public func newPushMessageRecived(_ userInfo: [AnyHashable: Any]) {
        self.fcmService.didReceiveDataMessage(userInfo)
    }
    
    private func handleSharedCollection(url: URL) {
        
        let handled: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.router.showSharedReadCollection(collection)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.shareCollectionHandleUsecase.loadSharedCollection(by: url)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: handled, onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - handle remind

extension ApplicationViewModelImple {
    
    private func handleRemindMessage(_ message: ReadRemindMessage) {
        let handleed = self.router.showRemindItem(message.itemID)
        guard handleed == false else { return }
        self.pendingShowRemindMessage = message
    }
    
    private func showDetailIfNeed() {
        guard let pending = self.pendingShowRemindMessage else { return }
        _ = self.router.showRemindItem(pending.itemID)
        self.pendingShowRemindMessage = nil
    }
}

// Prenseter

extension ApplicationViewModelImple {
    
}


private extension FCMService {
    
    var receiveReadmindMessage: Observable<ReadRemindMessage> {
        return self.receivePushMessage
            .compactMap { $0 as? ReadRemindMessage }
    }
}
