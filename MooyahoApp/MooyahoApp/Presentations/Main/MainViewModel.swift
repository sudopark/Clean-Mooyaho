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
    
    private weak var nearbySceneInteractor: NearbySceneInteractor?
    
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
        
        let scene = self.router.addNearbySceen()
        // TOOD: bind presenter
        self.nearbySceneInteractor = scene.ineteractor
    }
    
    public func openSlideMenu() {
        self.router.openSlideMenu()
    }
    
    public func moveMapCameraToCurrentUserPosition() {
        self.nearbySceneInteractor?.moveMapCameraToCurrentUserPosition()
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
        
        guard let events = self.router.presentSignInScene() else { return }
        events.signedIn
            .subscribe(onNext: { [weak self] in
                self?.makeNewHooray()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func requestEnerMemberProfileAndWaitResult() {
        
        let routeToEditProfile: () -> Void = { [weak self] in
            guard let self = self else { return }
            let presenter = self.router.presentEditProfileScene()
            self.bindEditProfileEndEvent(presenter)
        }
        
        guard let form = AlertBuilder(base: .init())
                .message("[TBD] need profile")
                .isSingleConfirmButton(true)
                .confirmed(routeToEditProfile)
                .build() else { return }
        
        self.router.alertForConfirm(form)
    }
    
    private func bindEditProfileEndEvent(_ presenter: EditProfileScenePresenter?) {
        presenter?.editCompleted
            .subscribe(onNext: { [weak self] in
                self?.makeNewHooray()
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
    
}
