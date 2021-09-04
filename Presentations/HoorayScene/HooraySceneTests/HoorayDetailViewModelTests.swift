//
//  HoorayDetailViewModelTests.swift
//  HooraySceneTests
//
//  Created by sudo.park on 2021/08/26.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

import HoorayScene


class HoorayDetailViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var dummyHoorayDetail: HoorayDetail!
    var dummyHooray: Hooray! { self.dummyHoorayDetail.hoorayInfo }
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        let uid = "uid:0"
        let acks = (0..<3).map{ HoorayAckInfo(hoorayID: uid,
                                              ackUserID: "a:\($0)", ackAt: TimeStamp($0))}
        let reactions = (0..<3).map { HoorayReaction(hoorayID: uid,
                                                     reactionID: "r:\($0)",
                                                     reactMemberID: "m:\($0)",
                                                     icon: .emoji("🤓"), reactAt: TimeStamp($0))}
        self.dummyHoorayDetail = .dummy(0, acks: acks, reactions: reactions)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.dummyHoorayDetail = nil
    }
    
    func makeViewModel(shouldLoadDetailFail: Bool = false) -> HoorayDetailViewModel {
        
        let hoorayID = self.dummyHooray.uid
        
        var hoorayScenario = BaseStubHoorayUsecase.Scenario()
        hoorayScenario.loadHoorayResult = shouldLoadDetailFail
            ? .failure(ApplicationErrors.invalid)
            : .success(self.dummyHoorayDetail)
        let stubHoorayUsecase = BaseStubHoorayUsecase(hoorayScenario)
        
        var memberScenario = BaseStubMemberUsecase.Scenario()
        let publisher = Member(uid: self.dummyHooray.publisherID, nickName: "some", icon: .emoji("😒"))
        memberScenario.members = .success([publisher])
        memberScenario.currentMember = Member(uid: self.dummyHoorayDetail.reactions.first?.reactMemberID ?? "some")
        let stubMemberUsecase = BaseStubMemberUsecase(scenario: memberScenario)
        
        let stubPlaceUsecase = StubPlaceUsecase()
        stubPlaceUsecase.stubPlace = Place.dummy(0)
        
        let stubRouter = StubRouter()
        
        return HoorayDetailViewModelImple(hoorayID: hoorayID,
                                          hoorayUsecase: stubHoorayUsecase,
                                          memberUsecase: stubMemberUsecase,
                                          placeUsecase: stubPlaceUsecase,
                                          router: stubRouter)
    }
}


// MARK: - show detail

extension HoorayDetailViewModelTests {
    
    func testViewModel_loadHoorayDetail() {
        // given
        let expect = expectation(description: "무야호 상세내역 조회 이후에 cellViewModel 방출")
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.loadDetail()
        }
        
        // then
        XCTAssertEqual(cellViewModels?.count, 3)
    }
    
    func testViewModel_whenLoadFailDetail_showLoadFailed() {
        // given
        let expect = expectation(description: "무야호 상세내역 조회 이후에 cellViewModel 방출")
        let viewModel = self.makeViewModel(shouldLoadDetailFail: true)
        
        // when
        let isLoadingFail: Void? = self.waitFirstElement(expect, for: viewModel.isLoadingFail) {
            viewModel.loadDetail()
        }
        
        // then
        XCTAssertNotNil(isLoadingFail)
    }
}

extension HoorayDetailViewModelTests {
    
    func testViewModel_headerCell() {
        // given
        let expect = expectation(description: "header cell")
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.loadDetail()
        }
        
        // then
        let headerCells = cellViewModels?.compactMap{ $0 as? HoorayDetailHeaderCellViewModel }
        XCTAssertEqual(headerCells?.count, 1)
    }
    
    func testViewModel_provideMemberInfo() {
        // given
        let expect = expectation(description: "member 정보 레이지하게 제공")
        let viewModel = self.makeViewModel()
        
        // when
        let publisherID = self.dummyHooray.publisherID
        let memberInfo = self.waitFirstElement(expect, for: viewModel.memberInfo(for: publisherID))
        
        // then
        XCTAssertNotNil(memberInfo)
    }
    
    func testViewModel_providePlaceName() {
        // given
        let expect = expectation(description: "장소 이름 제공")
        let viewModel = self.makeViewModel()
        
        // when
        let placeID = self.dummyHooray.placeID ?? "some"
        let placeName = self.waitFirstElement(expect, for: viewModel.placeName(for: placeID))
        
        // then
        XCTAssertNotNil(placeName)
    }
}


extension HoorayDetailViewModelTests {
    
    func testViewModel_contentCell() {
        // given
        let expect = expectation(description: "content cell 구성")
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.loadDetail()
        }
        
        // then
        let contentCells = cellViewModels?.compactMap{ $0 as? HoorayDetailContentCellViewModel }
        XCTAssertEqual(contentCells?.count, 1)
        XCTAssertEqual(contentCells?.first?.message, self.dummyHooray.message)
        XCTAssertEqual(contentCells?.first?.tags, self.dummyHooray.tags)
        XCTAssertEqual(contentCells?.first?.image, self.dummyHooray.image)
    }
}


// TODO: 리액션도 통합으로 

extension HoorayDetailViewModelTests {
    
    func testViewModel_reactionsCell() {
        // given
        let expect = expectation(description: "content cell 구성")
        let viewModel = self.makeViewModel()
        
        // when
        let cellViewModels = self.waitFirstElement(expect, for: viewModel.cellViewModels) {
            viewModel.loadDetail()
        }
        
        // then
        let reactionsCells = cellViewModels?.compactMap{ $0 as? HoorayDetailReactionsCellViewModel }
        XCTAssertEqual(reactionsCells?.count, 1)
    }
    
    func testViewModel_provideAckCount() {
        // given
        let expect = expectation(description: "ack count 제공")
        let viewodel = self.makeViewModel()
        
        // when
        let counts = self.waitFirstElement(expect, for: viewodel.ackCount, skip: 1) {
            viewodel.loadDetail()
        }
        
        // then
        XCTAssertEqual(counts, 3)
    }
    
    func testViewModel_provideReactions() {
        // given
        let expect = expectation(description: "reaction 제공")
        let viewodel = self.makeViewModel()
        
        // when
        let reactions = self.waitFirstElement(expect, for: viewodel.reactions, skip: 1) {
            viewodel.loadDetail()
        }
        
        // then
        XCTAssertEqual(reactions?.count, 1)
        XCTAssertEqual(reactions?.first?.icon, .emoji("🤓"))
        XCTAssertEqual(reactions?.first?.count, 3)
    }
    
    func testViewModel_provideReactionWithIsMineMark() {
        // given
        let expect = expectation(description: "reaction 제공시 내가 반응했나 정보도 같이 제공")
        let viewodel = self.makeViewModel()
        
        // when
        let reactions = self.waitFirstElement(expect, for: viewodel.reactions, skip: 1) {
            viewodel.loadDetail()
        }
        
        // then
        let myReactions = reactions?.filter{ $0.isIncludeMine }
        XCTAssertEqual(myReactions?.count, 1)
    }
}


// TODO: 코멘트는 추후 통합 코멘트로 붙임
extension HoorayDetailViewModelTests {
    
    // comments
}



extension HoorayDetailViewModelTests {
    
    class StubRouter: HoorayDetailRouting { }
    
    class StubPlaceUsecase: BaseStubPlaceUsecase {
        
        var stubPlace: Place?
        
        override func place(_ placeID: String) -> Observable<Place> {
            return self.stubPlace.map{ Observable.just($0) } ?? .error(ApplicationErrors.invalid)
        }
    }
}
