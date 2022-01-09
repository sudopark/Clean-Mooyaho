//
//  StopShareCollectionViewModelTests.swift
//  DiscoveryScene
//
//  Created by sudo.park on 2021/11/16.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import DiscoveryScene


class StopShareCollectionViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var spyRouter: SpyRouter!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
    }
    
    private var dummyCollectionID: String { "some" }
    private var dummySharedMemberIDs: [String] {
        return (0..<10).map { "id:\($0)" }
    }
    
    private func makeViewModel() -> StopShareCollectionViewModelImple {
        
        let shareUsecase = StubShareItemUsecase()
        shareUsecase.scenario.loadSharedMemberIDsResult = .success(self.dummySharedMemberIDs)
        
        let router = SpyRouter()
        self.spyRouter = router
        
        return StopShareCollectionViewModelImple(shareURLScheme: "prefix",
                                                 collectionID: self.dummyCollectionID,
                                                 shareCollectionUsecase: shareUsecase,
                                                 router: router, listener: nil)
    }
}


extension StopShareCollectionViewModelTests {
    
    func testViewModel_showSharingCollectionTitle() {
        // given
        let expect = expectation(description: "공유중인 콜렉션 타이틀 노출")
        let viewModel = self.makeViewModel()
        
        // when
        let title = self.waitFirstElement(expect, for: viewModel.collectionTitle) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertNotNil(title)
    }
        
    func testViewModel_openShare() {
        // given
        let expect = expectation(description: "공유하기 열기")
        let viewModel = self.makeViewModel()
        
        // when
        let _ = self.waitFirstElement(expect, for: viewModel.collectionTitle) {
            viewModel.refresh()
        }
        viewModel.openShare()
        
        // then
        XCTAssertNotNil(self.spyRouter.didPresentShareWith)
    }
    
    func testViewModel_provideSharedMemberCount() {
        // given
        let expect = expectation(description: "몇명이 해당 콜렉션을 공유받았는지 정보 제공")
        let viewModel = self.makeViewModel()
        
        // when
        let count = self.waitFirstElement(expect, for: viewModel.sharedMemberCount) {
            viewModel.refresh()
        }
        
        // then
        XCTAssertEqual(count, 10)
    }
    
    func testViewModel_findShareMember() {
        // given
        let expect = expectation(description: "공유받은 멤버 찾기 열기")
        let viewModel = self.makeViewModel()
        
        // when
        let _ = self.waitFirstElement(expect, for: viewModel.collectionTitle) {
            viewModel.refresh()
        }
        viewModel.findWhoSharedThieList()
        
        // then
        XCTAssertNotNil(self.spyRouter.didFindMemberFor)
    }
    
    func testViewModel_whenSharedMemberExcluded_updateSharedMemberCount() {
        // given
        let expect = expectation(description: "공유받는중인 멤버 제거시에 전체 카운트 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel()
        let dummyID = self.dummySharedMemberIDs.randomElement()!
        
        // when
        let counts = self.waitElements(expect, for: viewModel.sharedMemberCount) {
            viewModel.refresh()
            viewModel.sharedMemberListDidExcludeMember(dummyID)
        }
        
        // then
        XCTAssertEqual(counts, [10, 9])
    }
}

extension StopShareCollectionViewModelTests {
    
    func testViewModel_whenRequestStopShare_showConfirmAndStopSharing() {
        // given
        let expect = expectation(description: "공유 중지 요청시에 확인팝업 보이고 공유 중지")
        let viewModel = self.makeViewModel()
        
        self.spyRouter.didClose = {
            expect.fulfill()
        }
        
        // when
        viewModel.requestStopShare()
        let form = self.spyRouter.didConfirm
        form?.confirmed?()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
}



extension StopShareCollectionViewModelTests {
    
    class SpyRouter: StopShareCollectionRouting {
        
        var didClose: (() -> Void)?
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            self.didClose?()
        }
        
        var didAlertErrror = false
        func alertError(_ error: Error) {
            self.didAlertErrror = true
        }
        
        var didPresentShareWith: String?
        func presentShareSheet(with url: String) {
            didPresentShareWith = url
        }
        
        var didConfirm: AlertForm?
        func alertForConfirm(_ form: AlertForm) {
            self.didConfirm = form
        }
        
        var didFindMemberFor: SharedReadCollection?
        func findWhoSharedReadCollection(_ sharedCollection: SharedReadCollection, memberIDs: [String]) {
            self.didFindMemberFor = sharedCollection
        }
    }
}
