//
//  MainSlideMenuViewModelTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/11/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import MooyahoApp


class MainSlideMenuViewModelTests: BaseTestCase, WaitObservableEvents, MainSlideMenuSceneListenable, MainSlideMenuRouting {
    
    var disposeBag: DisposeBag!
    
    var didRequestSignIn: Bool?
    func mainSlideMenuDidRequestSignIn() {
        self.didRequestSignIn = true
    }
    
    var didClose: Bool?
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    var didSetupDiscovertyScene: Bool?
    func setupDiscoveryScene() {
        self.didSetupDiscovertyScene = true
    }
    
    func closeMenu() {
        self.closeScene(animated: true, completed: nil)
    }
    
    var didRouteToEditProfile: Bool?
    func editProfile() {
        self.didRouteToEditProfile = true
    }
    
    var didOpenSetting: Bool?
    func openSetting() {
        self.didOpenSetting = true
    }
    
    func mainSlideMenu(notifyDidSignedIn member: Member) {
     
    }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didRequestSignIn = nil
        self.didClose = nil
        self.didSetupDiscovertyScene = nil
        self.didRouteToEditProfile = nil
        self.didOpenSetting = nil
    }
    
    private func makeViewModel(member: Member? = nil) -> MainSlideMenuViewModel {
        
        let scenario = BaseStubMemberUsecase.Scenario()
            |> \.currentMember .~ member
        let stubUsecase = BaseStubMemberUsecase(scenario: scenario)
        return MainSlideMenuViewModelImple(memberUsecase: stubUsecase,
                                           router: self, listener: self)
    }
}


extension MainSlideMenuViewModelTests {
    
    func testViewModel_whenRefresh_setupDiscoveryScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.refresh()
        
        // then
        XCTAssertEqual(self.didSetupDiscovertyScene, true)
    }
    
    func testViewModel_closeScene() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.refresh()
        viewModel.closeMenu()
        
        // then
        XCTAssertEqual(self.didClose, true)
    }
    
    func testViewModel_openSetting() {
        // given
        let viewModel = self.makeViewModel(member: nil)
        
        // when
        viewModel.openSetting()
        
        // then
        XCTAssertEqual(self.didOpenSetting, true)
    }
}


// MARK: - signOut

extension MainSlideMenuViewModelTests {
    
    func testViewModel_whenSignOut_suggestActionIsSignIn() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 제안하는 동작은 로그인")
        let viewModel = self.makeViewModel(member: nil)
        
        // when
        let action = self.waitFirstElement(expect, for: viewModel.suggestingAction) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(action?.isSignIn, true)
    }
    
    func testViewModel_whenSignOut_disableDiscovery() {
        // given
        let expect = expectation(description: "로그아웃상태에서는 탐색 불가")
        let viewModel = self.makeViewModel(member: nil)
        
        // when
        let isDiscovable = self.waitFirstElement(expect, for: viewModel.isDiscovable) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isDiscovable, false)
    }
    
    func testViewModel_whenRequestSuggestedActionWithoutSignIn_closeSceneAndRequestSignIn() {
        // given
        let viewModel = self.makeViewModel(member: nil)
        
        // when
        viewModel.refresh()
        viewModel.suggestingActionRequested()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didRequestSignIn, true)
    }
}

// MARK: - signIn

extension MainSlideMenuViewModelTests {
    
    private func member(with nickname: String? = nil) -> Member {
        return Member(uid: "some", nickName: nickname, icon: nil)
    }
    
    func testViewModel_whenSignIn_suggestActionIsEditProfile() {
        // given
        let expect = expectation(description: "로그인상태에서는 프로필 수정으로 유도")
        let viewModel = self.makeViewModel(member: self.member(with: nil))
        
        // when
        let action = self.waitFirstElement(expect, for: viewModel.suggestingAction) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(action?.isEditProfle, true)
    }
    
    func testViewModel_whenSignIn_enableDiscovery() {
        // given
        let expect = expectation(description: "로그인 상태에서는 탐색 가능")
        let viewModel = self.makeViewModel(member: self.member(with: nil))
        
        // when
        let isDiscovable = self.waitFirstElement(expect, for: viewModel.isDiscovable) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(isDiscovable, true)
    }
    
    func testViewModel_whenRequestSuggestedActionWithSignIn_routeToEditProfile() {
        // given
        let viewModel = self.makeViewModel(member: self.member(with: nil))
        
        // when
        viewModel.refresh()
        viewModel.suggestingActionRequested()
        
        // then
        XCTAssertEqual(self.didRouteToEditProfile, true)
    }
}

private extension SuggestingAction {
    
    var isSignIn: Bool {
        guard case .signIn = self else { return false }
        return true
    }
    
    var isEditProfle: Bool {
        guard case .editProfile = self else { return false }
        return true
    }
    
    var presentingUserName: String? {
        guard case let .editProfile(userName) = self else { return nil }
        return userName
    }
}
