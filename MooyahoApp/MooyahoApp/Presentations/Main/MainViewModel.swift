//
//  MainViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import LocationScenes
import MemberScenes
import CommonPresenting

// MARK: - MainViewModel

public protocol MainViewModel: AnyObject {

    // interactor
    func setupSubScenes()
    func openSlideMenu()
    func moveMapCameraToCurrentUserPosition()
    func makeNewHooray()
    
    // presenter
}


// MARK: - MainViewModelImple

public final class MainViewModelImple: MainViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let auth: Auth
    private let hoorayUsecase: HoorayUsecase
    private let router: MainRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private weak var nearbySceneActionListener: NearbySceneCommandListener?
    
    public init(auth: Auth,
                hoorayUsecase: HoorayUsecase,
                router: MainRouting) {
        
        self.auth = auth
        self.hoorayUsecase = hoorayUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - MainViewModelImple Interactor

extension MainViewModelImple {
    
    public func setupSubScenes() {
        
        self.nearbySceneActionListener = self.router.addNearbySceen { [weak self] event in
            logger.print(level: .debug, "nearby event: \(event)")
        }
    }
    
    public func openSlideMenu() {
        self.router.openSlideMenu()
    }
    
    public func moveMapCameraToCurrentUserPosition() {
        self.nearbySceneActionListener?.moveMapCameraToCurrentUserPosition()
    }
    
    public func makeNewHooray() {
        
        let handleErrors: (Error) -> Void = { [weak self] error in
            switch error as? ApplicationErrors {
            case .sigInNeed: self?.requestSignInAndWaitResult()
            case .profileNotSetup: self?.requestEnerMemberProfileAndWaitResult()
            default: self?.router.alertError(error)
            }
        }
        
        let handleCheckResult: (Bool) -> Void = { [weak self] avail in
            logger.print(level: .debug, "neww hooray event: \(avail)")
        }
        
        self.hoorayUsecase.isAvailToPublish()
            .subscribe(onSuccess: handleCheckResult, onError: handleErrors)
            .disposed(by: self.disposeBag)
    }
    
    private func requestSignInAndWaitResult() {
        
        self.router.presentSignInScene { [weak self] event in
            switch event {
            case .signInSuccess:
                self?.makeNewHooray()
            }
        }
    }
    
    private func requestEnerMemberProfileAndWaitResult() {
        
        let handleEditEvent: (EditProfileSceneEvent) -> Void = { [weak self] event in
            guard case .editCompleted = event else { return }
            self?.makeNewHooray()
        }
        
        let routeToEditProfile: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.router.presentEditProfileScene(handleEditEvent)
        }
        
        guard let form = AlertBuilder(base: .init())
                .message("[TBD] need profile")
                .isSingleConfirmButton(true)
                .confirmed(routeToEditProfile)
                .build() else { return }
        
        self.router.alertForConfirm(form)
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
    
}
