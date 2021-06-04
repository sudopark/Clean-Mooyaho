//
//  MainViewModelTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import LocationScenes
import PlaceScenes
import MemberScenes
import StubUsecases
import UnitTestHelpKit

@testable import MooyahoApp


class MainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubHoorayUsecase: StubHoorayUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubHoorayUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = .init(auth: .init(userID: "some"),
                               hoorayUsecase: self.stubHoorayUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubHoorayUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension MainViewModelTests {
    
    private func linkMapScene() -> SpyNearbySceneInteractor {
        let spyInteractor = SpyNearbySceneInteractor()
        self.spyRouter.spyInteractor = spyInteractor
        self.viewModel.setupSubScenes()
        return spyInteractor
    }
    
    func testViewModel_requestMoveMapCameraToCurrentUserLocation() {
        // given
        let expect = expectation(description: "유저 현재위치로 지도 카메라 이동 요청")
        let interactor = self.linkMapScene()
        interactor.called(key: "moveMapCameraToCurrentUserPosition") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.moveMapCameraToCurrentUserPosition()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


// MARK: - test request make new hooray

extension MainViewModelTests {
    
    // auth가 준비되어야지
    
    func testViewModel_requestMakeNewHooray_withoutSignIn_routeToSignIn() {
        // given
        let expect = expectation(description: "새로운 후레이 발급 요청시 로그인되어있지 않다면 로그인 라우팅")
        self.stubHoorayUsecase.register(key: "isAvailToPublish") {
            return Maybe<Bool>.error(ApplicationErrors.sigInNeed)
        }
        
        self.spyRouter.called(key: "presentSignInScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.makeNewHooray()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_requestMakeNewHooray_withoutProfileSetup_routeToAlertEditProfile() {
        // given
        let expect = expectation(description: "새로운 후레이 발급 요청시 프로필이 세팅되어있지 않다면 않다면 입력 화면으로 이동 알럿")
        self.stubHoorayUsecase.register(key: "isAvailToPublish") {
            return Maybe<Bool>.error(ApplicationErrors.profileNotSetup)
        }
        
        self.spyRouter.called(key: "alertForConfirm") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.makeNewHooray()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension MainViewModelTests {
    
    class SpyRouter: MainRouting, Stubbable {
        
        func presentSignInScene() -> SignInScenePresenter? {
            self.verify(key: "presentSignInScene")
            return nil
        }
        
        var spyInteractor: SpyNearbySceneInteractor?
        func addNearbySceen() -> (ineteractor: NearbySceneInteractor?, presenter: NearbyScenePresenter?) {
            return (self.spyInteractor, nil)
        }
        
        func addSuggestPlaceScene() {
            
        }
        
        func openSlideMenu() {
            
        }
        
        func presentEditProfileScene() -> EditProfileScenePresenter? {
            self.verify(key: "presentEditProfileScene")
            return nil
        }
        
        func alertForConfirm(_ form: AlertForm) {
            self.verify(key: "alertForConfirm")
        }
    }
    
    class SpyNearbySceneInteractor: NearbySceneInteractor, Stubbable {
        
        func moveMapCameraToCurrentUserPosition() {
            self.verify(key: "moveMapCameraToCurrentUserPosition")
        }
    }
}
