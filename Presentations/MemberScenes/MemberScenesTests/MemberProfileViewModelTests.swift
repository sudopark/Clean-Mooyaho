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
}


extension MemberProfileViewModelTests {
    
    class SpyRouter: MemberProfileRouting {
        
    }
}
