//
//  SelectHoorayPlaceViewModelTests.swift
//  HooraySceneTests
//
//  Created by sudo.park on 2021/06/09.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import StubUsecases

@testable import HoorayScene


class SelectHoorayPlaceViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubLocationUsecase: StubUserLocationUsecase!
    var stubSuggestUsecase: StubSuggestPlaceUsecase!
    var spyRouter: SpyRouter!
    var viewModel: SelectHoorayPlaceViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubLocationUsecase = .init()
        self.stubSuggestUsecase = .init()
        self.spyRouter = .init()
        self.initViewModel()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubLocationUsecase = nil
        self.stubSuggestUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
    
    private func initViewModel() {
        self.viewModel = .init(form: .init(publisherID: "some"),
                               userLocationUsecase: self.stubLocationUsecase,
                               suggestPlaceUsecase: self.stubSuggestUsecase,
                               router: self.spyRouter)
    }
}

extension SelectHoorayPlaceViewModelTests {
    
    private func stubDefaultList(_ range: Range<Int> = (0..<1)) {
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.stubSuggestUsecase.register(type: SuggestPlaceResult.self, key: "startSuggestPlace:") {
            let dummies = range.map{ PlaceSnippet.dummy($0) }
            let result = SuggestPlaceResult(default: dummies)
            return result
        }
    }
    
    // 최초에 현재 유저위치 불러옴
    func testViewModel_firstLoadCurrentUserLocation() {
        // given
        let expect = expectation(description: "최초에 현재 유저위치 표시")
        self.stubDefaultList()
        
        // when
        self.initViewModel()
        let location = self.waitFirstElement(expect, for: self.viewModel.currentUserLocation) { }
        
        // then
        XCTAssertNotNil(location)
    }
    
    // 현재 유저위치 불러와서 -> 리스트 구성
    func testViewModel_firstSuggestPlacesNearbyUser() {
        // given
        let expect = expectation(description: "최초에 현재 유저위치 기준으로 장소 서제스트")
        self.stubDefaultList()
        
        // when
        self.initViewModel()
        let places = self.waitFirstElement(expect, for: self.viewModel.cellViewModels) { }
        
        // then
        XCTAssertEqual(places?.count, 1)
    }
    
    // 장소목록 키워드 필터링
    func testViewModel_filterPlacesByKeyword() {
        // given
        let expect = expectation(description: "장소 서제스트목록 키워드 필터링")
        expect.expectedFulfillmentCount = 2
        
        self.stubDefaultList()
        self.stubSuggestUsecase.register(type: SuggestPlaceResult.self, key: "startSuggestPlace:some") {
            let result = SuggestPlaceResult(default: [PlaceSnippet.dummy(1)])
            return result
        }
        
        // when
        self.initViewModel()
        let placeLists = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.viewModel.suggestPlace(by: "some")
        }
        
        // then
        let (page1, page2) = (placeLists.first, placeLists.last)
        XCTAssertEqual(page1?.count, 1)
        XCTAssertEqual(page1?.first?.placeID, "uid:0")
        XCTAssertEqual(page2?.count, 1)
        XCTAssertEqual(page2?.first?.placeID, "uid:1")
    }
    
    // 항목 선택시에 체크토글
    func testViewModel_whenSelectPlace_updateList() {
        // given
        let expect = expectation(description: "장소 선택시에 선택플래그 토글")
        expect.expectedFulfillmentCount = 4
        self.stubDefaultList(0..<10)
        
        // when
        self.initViewModel()
        let selectedIDSource = self.viewModel.cellViewModels.map{ $0.filter{ $0.isSelected } }
        let selectedIDLists = self.waitElements(expect, for: selectedIDSource) {
            self.viewModel.toggleUpdateSelected("uid:2")
            self.viewModel.toggleUpdateSelected("uid:4")
            self.viewModel.toggleUpdateSelected("uid:4")
        }
        
        // then
        let selectedIDs = selectedIDLists.map{ $0.first?.placeID }
        XCTAssertEqual(selectedIDs, [nil, "uid:2", "uid:4", nil])
    }
    
    // 항목 선택시에 아이콘
    func testViewModel_whenSelectPlace_updateSelectPlaceID() {
        // given
        let expect = expectation(description: "장소 선택시에 선택플래그 토글")
        self.stubDefaultList(0..<10)
        
        // when
        self.initViewModel()
        let selectedID = self.waitFirstElement(expect, for: self.viewModel.selectedPlaceID) {
            self.viewModel.toggleUpdateSelected("uid:3")
        }
        
        // then
        XCTAssertEqual(selectedID, "uid:3")
    }
    
    // 항목 선택시에 입력종료 버튼 활성화
    func testViewModel_updateFinishInputEnable_bySelectedInfo() {
        // given
        let expect = expectation(description: "선택된 장소정보 여부에 따라 입력 종료버튼 활성화")
        expect.expectedFulfillmentCount = 3
        self.stubDefaultList(0..<10)

        // when
        self.initViewModel()
        let isEnableds = self.waitElements(expect, for: self.viewModel.isFinishInputEnabled) {
            self.viewModel.toggleUpdateSelected("uid:3")
            self.viewModel.toggleUpdateSelected("uid:3")
        }

        // then
        XCTAssertEqual(isEnableds, [false, true, false])
    }
    
    func testViewModel_refreshSuggestPlace() {
        // given
        let expect = expectation(description: "유저위치 기준 서제스트 새로고침")
        expect.expectedFulfillmentCount = 2
        self.stubDefaultList(0..<2)
        self.initViewModel()
        
        // when
        let cellViewModelLists = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.viewModel.refreshUserLocation()
        }
        
        // then
        XCTAssertEqual(cellViewModelLists.count, 2)
    }
}

extension SelectHoorayPlaceViewModelTests {
    
    // 스킵시 알럿
    func testViewModel_whenSkipPlaceInput_alert() {
        // given
        let expect = expectation(description: "장소정보 입력 스킵시도시에 알럿")
        self.stubDefaultList(0..<10)
        self.initViewModel()
        
        self.spyRouter.called(key: "alertForConfirm") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.skipPlaceInput()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    func testViewModel_whenAfterConfirmSelect_closeSceneAndEmitEvent() {
        // given
        let expect = expectation(description: "장소선택 완료 이후에 화면 닫고 이벤트 전달")
        self.stubDefaultList(0..<10)
        self.initViewModel()
        
        // when
        let newForm = self.waitFirstElement(expect, for: self.viewModel.goNextStepWithForm) {
            self.viewModel.toggleUpdateSelected("uid:0")
            self.viewModel.confirmSelectPlace()
        }
        
        // then
        XCTAssertEqual(newForm?.placeID, "uid:0")
    }
    
    // 새위치 추가 라우팅
    func testViewModel_routeToRegisterNewPlace() {
        // given
        let expect = expectation(description: "장소정보 입력 스킵시도시에 알럿")
        self.stubDefaultList(0..<10)
        self.initViewModel()
        
        self.spyRouter.called(key: "presentNewPlaceRegisterScene") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.registerNewPlace()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 새위치 추가 완료시 위치 표시하고 닫기
    func testViewModel_whenRegisterNewPlaceEnd_finishPlaceSelection() {
        // given
        let expect = expectation(description: "신규 장소등록 다 끝낸 이후에 장소선택 완료")
        self.initViewModel()
        
        let output = StubSearchNewPlaceSceneOutput()
        self.spyRouter.stubOutput = output
        
        // when
        let newForm = self.waitFirstElement(expect, for: self.viewModel.goNextStepWithForm) {
            self.viewModel.registerNewPlace()
            
            let newPlace = Place.dummy(0)
            output.place.onNext(newPlace)
        }
        
        // then
        XCTAssertEqual(newForm?.placeID, "uid:0")
        XCTAssertEqual(newForm?.placeName, "title:0")
    }
}


extension SelectHoorayPlaceViewModelTests {
    
    class SpyRouter: SelectHoorayPlaceRouting, Stubbable {
        
        func alertForConfirm(_ form: AlertForm) {
            self.verify(key: "alertForConfirm")
        }
        
        var stubOutput: StubSearchNewPlaceSceneOutput?
        func presentNewPlaceRegisterScene(myID: String) -> SearchNewPlaceSceneOutput? {
            self.verify(key: "presentNewPlaceRegisterScene")
            return stubOutput
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            completed?()
        }
    }
    
    class StubSearchNewPlaceSceneOutput: SearchNewPlaceSceneOutput {
        let place = PublishSubject<Place>()
        var newRegistered: Observable<Place> {
            return self.place.asObservable()
        }
    }
}
