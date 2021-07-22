//
//  ManuallyResigterPlaceViewModelTests.swift
//  PlaceScenesTests
//
//  Created by sudo.park on 2021/06/12.
//

import XCTest

import RxSwift
import RxCocoa

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import PlaceScenes


class ManuallyResigterPlaceViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockLocationUsecase: MockUserLocationUsecase!
    var mockRegisterUsecase: MockRegisterNewPlaceUsecase!
    var spyRouter: SpyRouter!
    var viewModel: ManuallyResigterPlaceViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockLocationUsecase = .init()
        self.mockRegisterUsecase = .init()
        self.spyRouter = .init()
        self.initViewModel()
    }
    
    private func initViewModel() {
        self.viewModel = .init(userID: "some",
                               userLocationUsecase: self.mockLocationUsecase,
                               registerUsecase: self.mockRegisterUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.viewModel = nil
        self.mockLocationUsecase = nil
        self.mockRegisterUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension ManuallyResigterPlaceViewModelTests {
        
    // 이전에 입력하던거 (유효한) 거 있으면 해당 정보 출력
    func testViewModel_showPendingInput_ifExists() {
        // given
        let expect = expectation(description: "이전에 입력하던 항목이 있으면 최초에 보여줌")
        
        self.mockLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.mockRegisterUsecase.register(type: Maybe<NewPlaceForm?>.self,
                                          key: "loadRegisterPendingNewPlaceForm") {
            let form = NewPlaceForm(reporterID: "some", infoProvider: .userDefine)
            form.title = "title"
            form.address = "addr"
            return .just(form)
        }
        
        // when
        self.initViewModel()
        let title = self.viewModel.placeTitle
        let address = self.viewModel.placeAddress
        let previousInputSource = Observable.combineLatest(title, address)
        let previousInput = self.waitFirstElement(expect, for: previousInputSource)
        
        // then
        XCTAssertNotNil(previousInput)
    }
}

extension ManuallyResigterPlaceViewModelTests {
    
    private func registerEnterText() -> MockTextInputScenePresenter {
        let resultMocking = MockTextInputScenePresenter()
        self.spyRouter.register(type: TextInputSceneOutput.self,
                                key: "openPlaceTitleInputScene") {
            return resultMocking
        }
        return resultMocking
    }
    
    private func registerSelectLocation() -> MockLocationSelectScenePresenter {
        let resultMocking = MockLocationSelectScenePresenter()
        self.spyRouter.register(type: LocationSelectSceneOutput.self,
                                key: "openLocationSelectScene") {
            return resultMocking
        }
        return resultMocking
    }
    
    // 이름 입력 -> 타이틀 업데이트
    func testViewModel_afterEnterTitle_update() {
        // given
        let expect = expectation(description: "타이틀 입력 이후에 업데이트")
        
        let resultMocking = self.registerEnterText()
        
        // when
        let title = self.waitFirstElement(expect, for: self.viewModel.placeTitle) {
            self.viewModel.requestEnterText()
            resultMocking.subject.onNext("title")
        }
        
        // then
        XCTAssertEqual(title, "title")
    }
    
    // 장소 입력 -> 주소 업데이트
    func testViewModel_afterEnterLocation_updateAddress() {
        // given
        let expect = expectation(description: "장소 입력 이후에 주소 업데이트")
        let resultMocking = self.registerSelectLocation()
        
        self.viewModel.showup()
        
        // when
        let address = self.waitFirstElement(expect, for: self.viewModel.placeAddress) {
            self.viewModel.requestSelectPosition()
            var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
            location.placeMark = .init(address: "addr")
            resultMocking.subject.onNext(location)
        }
        
        // then
        XCTAssertEqual(address, "addr")
    }
    
    // 장소 입력 완료시에 지도 노출
    func testViewModel_afterEnterLocation_updatePosition() {
        // given
        let expect = expectation(description: "장소 입력 이후에 위치 업데이트")
        let resultMocking = self.registerSelectLocation()
        
        // when
        let location = self.waitFirstElement(expect, for: self.viewModel.placeLocation) {
            self.viewModel.requestSelectPosition()
            var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
            location.placeMark = .init(address: "addr")
            resultMocking.subject.onNext(location)
        }
        
        // then
        XCTAssertNotNil(location)
    }
    
    // 태그 입력 -> 태그목록 업데이트
    func testViewModel_afterEnterTag_update() {
        // given
        let expect = expectation(description: "태그 입력 이후에 업데이트")
        
        let resultMocking = MockSelectTagScenePresenter()
        self.spyRouter.register(type: SelectTagSceneOutput.self,
                                key: "openTagSelectScene") {
            return resultMocking
        }
        
        // when
        let tags = self.waitFirstElement(expect, for: self.viewModel.selectedTags) {
            self.viewModel.requestEnterCategoryTag()
            resultMocking.subject.onNext([Tag(placeCat: "some", emoji: "🏄‍♂️")])
        }
        
        // then
        XCTAssertEqual(tags?.count, 1)
    }
}

extension ManuallyResigterPlaceViewModelTests {
    
    private func registerAndEnterRequireInfos() {
        let titleResultMocking = self.registerEnterText()
        let locationResultMocking = self.registerSelectLocation()
        
        self.viewModel.requestEnterText()
        titleResultMocking.subject.onNext("some")
        
        self.viewModel.requestSelectPosition()
        var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
        location.placeMark = .init(address: "addr")
        locationResultMocking.subject.onNext(location)
    }
    
    // 이름 + 장소 입력 되어있으면 등록버튼 활성화
    func testViewModel_enableRegistable_whenTitleAndAddressEntered() {
        // given
        let expect = expectation(description: "이름과 장소가 입력되었을때 등록버튼 활성화")
        expect.expectedFulfillmentCount = 2
        
        // when
        let isRegistables = self.waitElements(expect, for: self.viewModel.isRegistable) {
            self.registerAndEnterRequireInfos()
        }
        
        // then
        XCTAssertEqual(isRegistables, [false, true])
    }
    
    func testViewModel_savePendingInput() {
        // given
        let expect = expectation(description: "입력중이던 정보 저장")
        
        let titleResultMocking = self.registerEnterText()
        
        self.mockRegisterUsecase.called(key: "finishInputPlaceInfo") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestEnterText()
        titleResultMocking.subject.onNext("some")
        self.viewModel.savePendingInput()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 등록 요청 -> 새로운 장소 방출
    func testViewModel_registerNewPlace() {
        // given
        let expect = expectation(description: "장소 저장 이후 새로운 장소 이벤트 방출")
        
        self.mockRegisterUsecase.register(key: "uploadNewPlace") {
            return Maybe<Place>.just(.dummy(0))
        }
        
        // when
        let newPlace = self.waitFirstElement(expect, for: self.viewModel.newPlace) {
            self.registerAndEnterRequireInfos()
            self.viewModel.requestRegister()
        }
        
        // then
        XCTAssertNotNil(newPlace)
    }
}


extension ManuallyResigterPlaceViewModelTests {
    
    class SpyRouter: ManuallyResigterPlaceRouting, Mocking {
        
        func addSmallMapView() -> LocationMarkSceneInput? {
            return nil
        }
        
        func openPlaceTitleInputScene(_ mode: TextInputMode) -> TextInputSceneOutput? {
            return self.resolve(TextInputSceneOutput.self, key: "openPlaceTitleInputScene")
        }
        
        func openLocationSelectScene(_ previousInfo: PreviousSelectedLocationInfo?) -> LocationSelectSceneOutput? {
            return self.resolve(LocationSelectSceneOutput.self, key: "openLocationSelectScene")
        }
        
        func openTagSelectScene(_ tags: [Tag], total: [Tag]) -> SelectTagSceneOutput? {
            return self.resolve(SelectTagSceneOutput.self, key: "openTagSelectScene")
        }
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            completed?()
        }
    }
    
    class MockTextInputScenePresenter: TextInputSceneOutput {
        let subject = PublishSubject<String>()
        var enteredText: Observable<String> {
            return self.subject.asObservable()
        }
    }
    
    class MockLocationSelectScenePresenter: LocationSelectSceneOutput {
        let subject = PublishSubject<CurrentPosition>()
        var selectedLocation: Observable<CurrentPosition> {
            return self.subject.asObservable()
        }
    }
    
    class MockSelectTagScenePresenter: SelectTagSceneOutput {
        let subject = PublishSubject<[Tag]>()
        var selectedTags: Observable<[Tag]> {
            return subject.asObservable()
        }
    }
}
