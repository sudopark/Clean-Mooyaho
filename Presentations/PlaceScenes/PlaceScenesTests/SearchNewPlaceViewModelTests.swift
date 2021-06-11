//
//  SearchNewPlaceViewModelTests.swift
//  PlaceScenesTests
//
//  Created by sudo.park on 2021/06/11.
//

import XCTest

import RxSwift
import RxCocoa

import Domain
import UnitTestHelpKit
import StubUsecases

@testable import PlaceScenes


class SearchNewPlaceViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubUserLocationUsecase: StubUserLocationUsecase!
    var stubPlaceSearchUsecase: StubSearchNewPlaceUsecase!
    var spyRouter: SpyRouter!
    var viewModel: SearchNewPlaceViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubUserLocationUsecase = .init()
        self.stubPlaceSearchUsecase = .init()
        self.spyRouter = .init()
        self.stubUserLocationUsecase.register(key: "fetchUserLocation") {
            Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.initViewModel()
    }
    
    private func initViewModel() {
        self.viewModel = nil
        self.viewModel = .init(userID: "some",
                               searchServiceProvider: SearchServiceProviders.naver,
                               userLocationUsecase: self.stubUserLocationUsecase,
                               searchNewPlaceUsecase: self.stubPlaceSearchUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubUserLocationUsecase = nil
        self.stubPlaceSearchUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}

extension SearchNewPlaceViewModelTests {
    
    private func dummySearchResult(for query: SuggestPlaceQuery,
                                   pageIndex: Int? = nil,
                                   isFinalPage: Bool = false,
                                   range: Range<Int>) -> SearchingPlaceCollection {
        let places = range.map(SearchingPlace.dummy(_:))
        return .init(query: query.string, currentPage: pageIndex, places: places, isFinalPage: isFinalPage)
    }
    
    //  초기에 현재 유저위치 기준으로 디폴트 목록 보여줌
    func testViewModel_whenFirst_showDefaultListByUserCurrentLocation() {
        // given
        let expect = expectation(description: "초기에 현재 위치 기준으로 디폴트 검색결과 노출")
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        
        // when
        self.initViewModel()
        let cellViewModels = self.waitFirstElement(expect, for: self.viewModel.cellViewModels)
        
        // then
        XCTAssertEqual(cellViewModels?.first?.isAddNewPlaceCell, true)
        XCTAssertEqual(cellViewModels?.placeCellCount, 10)
    }
    
    // 결과 갱신시에 다시 유저위치 불러와서 디폴트 목록 보여줌
    func testViewModel_whenRefreshUserLocationAndResult_updateDefaultList() {
        // given
        let expect = expectation(description: "결과 갱신시에 유저위치도 갱신하고 다시 리스트 보여줌")
        expect.expectedFulfillmentCount = 2
        
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        // when
        let cellViewModelsList = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
                return self.dummySearchResult(for: .empty, range: (0..<20))
            }
            self.viewModel.refreshList()
        }
        
        // then
        let oldPagePlaceCount = cellViewModelsList.first?.placeCellCount
        let newPagePlaceCount = cellViewModelsList.last?.placeCellCount
        XCTAssertEqual(oldPagePlaceCount, 10)
        XCTAssertEqual(newPagePlaceCount, 20)
    }
    
    // 페이징 -> 끝까지
    func testViewModel_showDetaultListWithPaging_untilLastPage() {
        // given
        let expect = expectation(description: "마지막 페이지까지 검색결과 페이징")
        expect.expectedFulfillmentCount = 3
        
        let page1 = self.dummySearchResult(for: .empty, pageIndex: 1, range: (0..<10))
        let page2 = self.dummySearchResult(for: .empty, pageIndex: 2, range: (10..<20))
        let page3 = self.dummySearchResult(for: .empty, pageIndex: 3, isFinalPage: true, range: (20..<30))
        
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return page1
        }
        self.initViewModel()
        
        // when
        let cellViewModelsList = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "loadMorePlaceSearchResult") {
                return page2
            }
            self.viewModel.loadMore()
            
            self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "loadMorePlaceSearchResult") {
                return page3
            }
            self.viewModel.loadMore()
        }
        
        // then
        let cellIDList = cellViewModelsList.map{ $0.placeCellIDs }
        guard cellIDList.count == 3 else {
            XCTFail("기대하는 사이즈가 아님")
            return
        }
        XCTAssertEqual(cellIDList[0], page1.places.map{ $0.uid })
        XCTAssertEqual(cellIDList[1], page2.places.map{ $0.uid })
        XCTAssertEqual(cellIDList[2], page3.places.map{ $0.uid })
    }
    
    func testViewModel_showSearchingResult() {
        // given
        let expect = expectation(description: "검색결과로 리스트 업데이트")
        expect.expectedFulfillmentCount = 2
        
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        // when
        let cellViewModelsList = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:dummy") {
                return self.dummySearchResult(for: .some("dummy"), range: (0..<20))
            }
            self.viewModel.search("dummy")
        }
        
        // then
        let oldPagePlaceCount = cellViewModelsList.first?.placeCellCount
        let searchPagePlaceCount = cellViewModelsList.last?.placeCellCount
        XCTAssertEqual(oldPagePlaceCount, 10)
        XCTAssertEqual(searchPagePlaceCount, 20)
    }
}
 

extension SearchNewPlaceViewModelTests {
    
    // 선택시에 장소 상세화면으로 넘어감(링크 있으면) -> 웹뷰
    func testViewModel_whenSelectPlaceWhichHasDetailLink_showDetail() {
        // given
        let expect = expectation(description: "장소 선택시에 링크 있으면 상세화면으로 넘김")
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        self.spyRouter.called(key: "showPlaceDetail") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.toggleSelectPlace("uid:0")
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 선택시 선택 토글
    func testViewModel_toggleUpdateSelect() {
        // given
        let expect = expectation(description: "선택 토글")
        expect.expectedFulfillmentCount = 4
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        // when
        let cellViewModelLists = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.viewModel.toggleSelectPlace("uid:0")
            self.viewModel.toggleSelectPlace("uid:1")
            self.viewModel.toggleSelectPlace("uid:1")
        }
        
        // then
        guard cellViewModelLists.count == 4 else {
            XCTFail("기대하는 사이즈가 아님")
            return
        }
        XCTAssertEqual(cellViewModelLists[0].selectedCellID, nil)
        XCTAssertEqual(cellViewModelLists[1].selectedCellID, "uid:0")
        XCTAssertEqual(cellViewModelLists[2].selectedCellID, "uid:1")
        XCTAssertEqual(cellViewModelLists[3].selectedCellID, nil)
        
    }
    
    // 선택시에 완료버튼 활성화
    func testViewModel_updateConfirmButton_whenSelectPlaceExists() {
        // given
        let expect = expectation(description: "선택된 장소가있으면 확인버튼 활성화 업데이트")
        expect.expectedFulfillmentCount = 3
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        // when
        let isConfirmables = self.waitElements(expect, for: self.viewModel.isPlaceSelectConfirmable) {
            self.viewModel.toggleSelectPlace("uid:0")
            self.viewModel.toggleSelectPlace("uid:0")
        }
        
        // then
        XCTAssertEqual(isConfirmables, [false, true, false])
    }
    
    // 검색된 결과 선택한 상태에서 다른 검색으로 목록 사라지면 완료 버튼도 비활성화
    func testViewModel_whenSelectedCellDisappearBySearchResult_disableConfirmable() {
        // given
        let expect = expectation(description: "선택된 장소가 검색으로 인해 목록에서 사라지면 비활성화")
        expect.expectedFulfillmentCount = 3
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        // when
        let isConfirmables = self.waitElements(expect, for: self.viewModel.isPlaceSelectConfirmable) {
            self.viewModel.toggleSelectPlace("uid:0")
            
            self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:dummy") {
                return self.dummySearchResult(for: .some("dummy"), range: (10..<20))
            }
            self.viewModel.search("dummy")
        }
        
        // then
        XCTAssertEqual(isConfirmables, [false, true, false])
    }
}

extension SearchNewPlaceViewModelTests {
    
    func testViewModel_whenSelectConfirmed_routeToPlaceCateTagSelectScene() {
        // given
        let expect = expectation(description: "입력 완료시에 장소 종류 태그 입력화면으로 이동")
        self.stubPlaceSearchUsecase.register(type: SearchingPlaceCollection.self, key: "startSearchPlace:") {
            return self.dummySearchResult(for: .empty, range: (0..<10))
        }
        self.initViewModel()
        
        // when
        self.spyRouter.called(key: "") { _ in
            
        }
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 저장 완료시에 화면 닫고 장소 아이디랑 이름 외부로 전파
}


extension SearchNewPlaceViewModelTests {
    
    class SpyRouter: SearchNewPlaceRouting, Stubbable {
        
        func showPlaceDetail(_ placeID: String, link: String) {
            self.verify(key: "showPlaceDetail")
        }
    }
}


private extension Array where Element == SearchingNewPlaceCellViewModelType {
    
    var placeCellCount: Int {
        return self.filter{ $0 is SearchinNewPlaceCellViewModel }.count
    }
    
    var placeCellIDs: [String] {
        return self.compactMap{ $0 as? SearchinNewPlaceCellViewModel }
            .map{ $0.placeID }
    }
    
    var selectedCellID: String? {
        return self.compactMap{ $0 as? SearchinNewPlaceCellViewModel }
            .first(where: { $0.isSelected == true })
            .map{ $0.placeID }
    }
}

private extension SearchingNewPlaceCellViewModelType {
    
    var isAddNewPlaceCell: Bool {
        return self is SeerchingNewPlaceAddNewCellViewModel
    }
}
