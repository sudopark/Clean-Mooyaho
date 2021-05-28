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
import UnitTestHelpKit

@testable import MooyahoApp


class MainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.spyRouter = .init()
        self.viewModel = .init(router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension MainViewModelTests {
    
    private func linkMapScene() -> SpyNearbySceneListeningAction {
        let spyCommandListener = SpyNearbySceneListeningAction()
        self.spyRouter.stubCommandListener = spyCommandListener
        self.viewModel.setupSubScenes()
        return spyCommandListener
    }
    
    func testViewModel_requestMoveMapCameraToCurrentUserLocation() {
        // given
        let expect = expectation(description: "유저 현재위치로 지도 카메라 이동 요청")
        let spyCommandListener = self.linkMapScene()
        spyCommandListener.called(key: "updateCurrentUserPosition") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.moveMapCameraToCurrentUserPosition()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}


extension MainViewModelTests {
    
    class SpyRouter: MainRouting, Stubbable {
        
        func presentSignInScene() {
            
        }
        
        var stubCommandListener: SpyNearbySceneListeningAction?
        func addNearbySceen(_ listener: @escaping Listener<NearbySceneEvents>) -> NearbySceneCommandListener? {
            return self.stubCommandListener
        }
        
        func addSuggestPlaceScene(_ listener: @escaping Listener<SuggestSceneEvents>) {
            
        }
        
        func openSlideMenu() {
            
        }
    }
    
    class SpyNearbySceneListeningAction: NearbySceneCommandListener, Stubbable {
        
        func moveMapCameraToCurrentUserPosition() {
            self.verify(key: "updateCurrentUserPosition")
        }
    }
}
