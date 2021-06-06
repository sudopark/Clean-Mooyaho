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
    var currentMemberProfileImage: Observable<ImageSource> { get }
}


// MARK: - MainViewModelImple

public final class MainViewModelImple: MainViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let memberUsecase: MemberUsecase
    private let hoorayUsecase: HoorayUsecase
    private let router: MainRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private weak var nearbySceneInteractor: NearbySceneInteractor?
    
    public init(memberUsecase: MemberUsecase,
                hoorayUsecase: HoorayUsecase,
                router: MainRouting) {
        
        self.memberUsecase = memberUsecase
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
            case let .shouldWaitPublishHooray(until): self?.router.alertShouldWaitPublishNewHooray(until)
            default: self?.router.alertError(error)
            }
        }
        
        let handleCheckResult: () -> Void = { [weak self] in
            logger.print(level: .debug, "start make new hooray")
            self?.router.presentMakeNewHoorayScene()
        }
        
        self.hoorayUsecase.isAvailToPublish()
            .subscribe(onSuccess: handleCheckResult, onError: handleErrors)
            .disposed(by: self.disposeBag)
    }
    
    private func requestSignInAndWaitResult() {
        
        guard let events = self.router.presentSignInScene() else { return }
        events.signedIn
            .subscribe(onNext: { [weak self] in
                self?.router.presentMakeNewHoorayScene()
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
                self?.router.presentMakeNewHoorayScene()
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
 
    public var currentMemberProfileImage: Observable<ImageSource> {
        return self.memberUsecase.currentMember
            .compactMap{ $0?.icon }
            .startWith(Member.memberDefaultEmoji)
    }
}
