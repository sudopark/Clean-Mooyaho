//
//  RecoverAccountViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2022/01/09.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import MemberScenes


class RecoverAccountViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: SpyRouter!
    private var spyListener: SpyListener!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.spyListener = nil
    }
    
    private func makeViewModel() -> RecoverAccountViewModel {
        
        let oldMember = Member(uid: "some", nickName: nil, icon: nil)
            |> \.deactivatedDateTimeStamp .~ Date(timeIntervalSinceReferenceDate: 0).timeIntervalSince1970
        let newMember = oldMember |> \.deactivatedDateTimeStamp .~ nil
        
        let scenario = BaseStubMemberUsecase.Scenario()
            |> \.currentMember .~ oldMember
        let memberUsecase = BaseStubMemberUsecase(scenario: scenario)
        
        let authUsecase = MockAuthUsecase()
            |> \.recoveredMember .~ newMember
        
        let router = SpyRouter()
        self.spyRouter = router
        
        let listener = SpyListener()
        self.spyListener = listener
        
        return RecoverAccountViewModelImple(authUsecase: authUsecase,
                                            memberUsecase: memberUsecase,
                                            router: router,
                                            listener: listener)
    }
}

extension RecoverAccountViewModelTests {
    
    func testViewModel_provideMemberInfo() {
        // given
        let expect = expectation(description: "멤버 정보 제공")
        let viewModel = self.makeViewModel()
        
        // when
        let info = self.waitFirstElement(expect, for: viewModel.memberInfo)
        
        // then
        XCTAssertNotNil(info)
    }
    
    func testViewModel_provideDeactiveDateText() {
        // given
        let expect = expectation(description: "비활성화 일자 정보 제공")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        
        // when
        let texts = self.waitElements(expect, for: viewModel.deactivateDateText) {
            viewModel.confirmRecover()
        }
        
        // then
        XCTAssertEqual(texts, ["Withdrawal request date: 2001.01.01", ""])
    }
}

extension RecoverAccountViewModelTests {
    
    func testViewModel_whenRecoverAccount_updateIsRecovering() {
        // given
        let expect = expectation(description: "비활성화시에 비활성화 플래그 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let isRecoverings = self.waitElements(expect, for: viewModel.isRecovering) {
            viewModel.confirmRecover()
        }
        
        // then
        XCTAssertEqual(isRecoverings, [false, true, false])
    }
    
    func testViewModel_whenAfterRecoverAccount_showToastAndClose() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.confirmRecover()
        
        // then
        XCTAssertEqual(self.spyRouter.didClose, true)
        XCTAssertEqual(self.spyListener.didAccountRecovered, true)
    }
}

extension RecoverAccountViewModelTests {
    
    class SpyRouter: RecoverAccountRouting {
     
        var didShowToast: Bool?
        func showToast(_ message: String) {
            self.didShowToast = true
        }
        
        var didClose: Bool?
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.didClose = true
            completed?()
        }
    }
    
    class SpyListener: RecoverAccountSceneListenable {
        
        var didAccountRecovered: Bool?
        func recoverAccount(didCompleted recoveredMember: Member) {
            self.didAccountRecovered = true
        }
    }
}
