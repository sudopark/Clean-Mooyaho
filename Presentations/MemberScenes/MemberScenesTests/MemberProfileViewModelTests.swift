//
//  MemberProfileViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2021/12/11.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import Extensions
import UnitTestHelpKit
import UsecaseDoubles

@testable import MemberScenes


class MemberProfileViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
    }
    
    private func makeViewModel(_ member: Member) -> MemberProfileViewModel {
        
        let scenario = BaseStubMemberUsecase.Scenario()
            |> \.loadMemberResult .~ .success([member])
        let usecase = BaseStubMemberUsecase(scenario: scenario)
        let router = SpyRouter()
        self.spyRouter = router
        return MemberProfileViewModelImple(memberID: member.uid,
                                           memberUsecase: usecase,
                                           router: router,
                                           listener: nil)
    }
    
    private var dummyMember: Member {
        return Member(uid: "some", nickName: "nick name", icon: .emoji("🚚"))
    }
    
    private var memberWithoutNickname: Member {
        return Member(uid: "some", nickName: nil, icon: nil)
    }
    
    private var memberWithoutThumbnail: Member {
        return Member(uid: "some", nickName: "nick name", icon: nil)
    }
}


extension MemberProfileViewModelTests {
    
    func testViewModel_provideProfileInfo() {
        // given
        let expect = expectation(description: "멤버정보 제공")
        let viewModel = self.makeViewModel(self.dummyMember)
        
        // when
        let source = viewModel.sections.compactMap { $0.first?.cellViewModels.first }.compactMap { $0 as? MemberInfoCellViewMdoel }
        let info = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(info?.displayName, "nick name")
        XCTAssertEqual(info?.thumbnail, .emoji("🚚"))
    }
    
    func testViewModel_whenNicknameNotExists_provideProfileInfo() {
        // given
        let expect = expectation(description: "닉네임 없을때 멤버정보 제공")
        let viewModel = self.makeViewModel(self.memberWithoutNickname)
        
        // when
        let source = viewModel.sections.compactMap { $0.first?.cellViewModels.first }.compactMap { $0 as? MemberInfoCellViewMdoel }
        let info = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(info?.displayName, "Unnamed member".localized)
        XCTAssertEqual(info?.thumbnail, .emoji("👻"))
    }
    
    func testViewModel_whenThumbnailNotExists_provideProfileInfo() {
        // given
        let expect = expectation(description: "섬네일 없을때 멤버정보 제공")
        let viewModel = self.makeViewModel(self.memberWithoutThumbnail)
        
        // when
        let source = viewModel.sections.compactMap { $0.first?.cellViewModels.first }.compactMap { $0 as? MemberInfoCellViewMdoel }
        let info = self.waitFirstElement(expect, for: source) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(info?.displayName, "nick name")
        XCTAssertEqual(info?.thumbnail, .emoji("👻"))
    }
    
    func testViewModel_provideIntro() {
        // given
        let expect = expectation(description: "소개 존재시 제공")
        let dummy = self.dummyMember |> \.introduction .~ "some intro"
        let viewModel = self.makeViewModel(dummy)
        
        // when
        let introSource = viewModel.sections
            .compactMap { $0.first?.cellViewModels }
            .map { $0.compactMap { $0 as? MemberIntroCellViewModel } }
            .compactMap { $0.first }
        let intro = self.waitFirstElement(expect, for: introSource) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(intro?.intro, "some intro")
    }
    
    func testViewModel_whenLoadDeactivatedMember_alertAndClose() {
        // given
        let dummy = self.dummyMember |> \.deactivatedDateTimeStamp .~ TimeStamp.now()
        let viewModel = self.makeViewModel(dummy)
        
        // when
        viewModel.refresh()
        
        // then
        XCTAssertEqual(self.spyRouter.didAlertForConfirm, true)
        XCTAssertEqual(self.spyRouter.didDismissed, true)
    }
}


extension MemberProfileViewModelTests {
    
    final class SpyRouter: MemberProfileRouting, @unchecked Sendable {
        
        var didAlertForConfirm: Bool?
        func alertForConfirm(_ form: AlertForm) {
            self.didAlertForConfirm = true
            form.confirmed?()
        }
        
        var didDismissed: Bool?
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.didDismissed = true
        }
    }
}
