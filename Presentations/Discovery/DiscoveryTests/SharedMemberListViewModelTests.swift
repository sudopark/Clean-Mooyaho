//
//  SharedMemberListViewModelTests.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2022/01/01.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles
@testable import DiscoveryScene


class SharedMemberListViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
    }
    
    private var dummyMembers: [Member] {
        return (0..<50).map { int -> Member in
            return Member(
                uid: "id:\(int)", nickName: "name:\(int)", icon: .imageSource(.init(path: "path:\(int)", size: nil))
            )
        }
    }
    
    private var dummyCollection: SharedReadCollection {
        return SharedReadCollection.dummy(100)
    }
    
    private func makeViewModel() -> SharedMemberListViewModelImple {
        
        let memeberScenario = BaseStubMemberUsecase.Scenario()
            |> \.members .~ .success(self.dummyMembers)
        let memberUsecase = BaseStubMemberUsecase(scenario: memeberScenario)
        
        let shareUsecase = StubShareItemUsecase()
        
        let router = SpyRouter()
        self.spyRouter = router
        
        return SharedMemberListViewModelImple(sharedCollection: self.dummyCollection,
                                              memberIDs: self.dummyMembers.map { $0.uid },
                                              memberUsecase: memberUsecase,
                                              shareReadCollectionUsecase: shareUsecase,
                                              router: router, listener: nil)
    }
}


extension SharedMemberListViewModelTests {
    
    // load members until end
    func testViewModel_loadMembersUntilEnd() {
        // given
        let expect = expectation(description: "마지막까지 멤버 로드")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModel, skip: 1) {
            viewModel.refresh()     // 0~20
            viewModel.loadMore()    // 20~40
            viewModel.loadMore()    // 40~50
            viewModel.loadMore()    // x
        }
        
        // then
        XCTAssertEqual(cvmLists.map { $0.count }, [20, 40, 50])
    }
    
    // provide member attribute
    func testViewModel_provideMemberAttribute() {
        // given
        let expect = expectation(description: "멤버 속성 제공")
        let viewModel = self.makeViewModel()
        
        // when
        let dummy = self.dummyMembers.last!
        let attribute = self.waitFirstElement(expect, for: viewModel.memberAttribute(for: dummy.uid)) {
            viewModel.refresh()     // x
            viewModel.loadMore()    // x
            viewModel.loadMore()    // load
        }
        
        // then
        XCTAssertNotNil(attribute)
    }
}

extension SharedMemberListViewModelTests {
    
    // exclude -> remove from list
    func testViewModel_exlcudeMemberFromCollectionSharing() {
        // given
        let expect = expectation(description: "해당 유저에게 읽기목록 공유 제거")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel()
        let dummy = self.dummyMembers.first!
        
        // when
        let cvmLists = self.waitElements(expect, for: viewModel.cellViewModel, skip: 1) {
            viewModel.refresh()
            viewModel.excludeMember(dummy.uid)
            viewModel.loadMore()
        }
        
        // then
        let memberIDLists = cvmLists.map { $0.map { $0.memberID } }
        XCTAssertEqual(memberIDLists.map { $0.contains(dummy.uid) }, [true, false, false])
    }
}


extension SharedMemberListViewModelTests {
    
    class SpyRouter: SharedMemberListRouting {
        
        var didConfirm: Bool?
        func alertForConfirm(_ form: AlertForm) {
            self.didConfirm = true
            form.confirmed?()
        }
        
        func showMemberProfile(_ memberID: String) {    
        }
    }
}
