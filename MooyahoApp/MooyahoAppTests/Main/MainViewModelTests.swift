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
import MemberScenes
import UsecaseDoubles
import UnitTestHelpKit

@testable import MooyahoApp


class MainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockMemberUsecase: MockMemberUsecase!
    var mockHoorayUsecase: MockHoorayUsecase!
    var spyRouter: SpyRouter!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockMemberUsecase = .init()
        self.mockHoorayUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = .init(memberUsecase: self.mockMemberUsecase,
                               hoorayUsecase: self.mockHoorayUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockMemberUsecase = nil
        self.mockHoorayUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension MainViewModelTests {
    
    func testViewModel_updateMemberProfileImage() {
        // given
        let expect = expectation(description: "멤버 프로필 섬네일 업데이트")
        expect.expectedFulfillmentCount = 2
        
        // when
        let profileImages = self.waitElements(expect, for: self.viewModel.currentMemberProfileImage) {
            var newMember = Member(uid: "some")
            newMember.icon = .emoji("😱")
            self.mockMemberUsecase.currentMemberSubject.onNext(newMember)
        }
        
        // then
        XCTAssertEqual(profileImages.count, 2)
    }
}


extension MainViewModelTests {
    
    class SpyRouter: MainRouting, Mocking {
        
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
        
        func alertShouldWaitPublishNewHooray(_ until: TimeStamp) {
            self.verify(key: "alertShouldWaitPublishNewHooray")
        }
        
        func presentMakeNewHoorayScene() {
            self.verify(key: "presentMakeNewHoorayScene")
        }
    }
    
    class SpyNearbySceneInteractor: NearbySceneInteractor, Mocking {
        
        func moveMapCameraToCurrentUserPosition() {
            self.verify(key: "moveMapCameraToCurrentUserPosition")
        }
    }
}
