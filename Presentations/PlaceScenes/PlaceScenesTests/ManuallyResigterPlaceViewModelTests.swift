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
import StubUsecases

@testable import PlaceScenes


class ManuallyResigterPlaceViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubLocationUsecase: StubUserLocationUsecase!
    var stubRegisterUsecase: StubRegisterNewPlaceUsecase!
    var spyRouter: SpyRouter!
    var viewModel: ManuallyResigterPlaceViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubLocationUsecase = .init()
        self.stubRegisterUsecase = .init()
        self.spyRouter = .init()
        self.initViewModel()
    }
    
    private func initViewModel() {
        self.viewModel = .init(userID: "some",
                               userLocationUsecase: self.stubLocationUsecase,
                               registerUsecase: self.stubRegisterUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.viewModel = nil
        self.stubLocationUsecase = nil
        self.stubRegisterUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension ManuallyResigterPlaceViewModelTests {
        
    // 이전에 입력하던거 (유효한) 거 있으면 해당 정보 출력
    func testViewModel_showPendingInput_ifExists() {
        // given
        let expect = expectation(description: "이전에 입력하던 항목이 있으면 최초에 보여줌")
        
        self.stubLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.stubRegisterUsecase.register(type: Maybe<NewPlaceForm?>.self,
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
    
    private func stubEnterText() -> StubTextInputScenePresenter {
        let stubResult = StubTextInputScenePresenter()
        self.spyRouter.register(type: TextInputSceneOutput.self,
                                key: "openPlaceTitleInputScene") {
            return stubResult
        }
        return stubResult
    }
    
    private func stubSelectLocation() -> StubLocationSelectScenePresenter {
        let stubResult = StubLocationSelectScenePresenter()
        self.spyRouter.register(type: LocationSelectSceneOutput.self,
                                key: "openLocationSelectScene") {
            return stubResult
        }
        return stubResult
    }
    
    // 이름 입력 -> 타이틀 업데이트
    func testViewModel_afterEnterTitle_update() {
        // given
        let expect = expectation(description: "타이틀 입력 이후에 업데이트")
        
        let stubResult = self.stubEnterText()
        
        // when
        let title = self.waitFirstElement(expect, for: self.viewModel.placeTitle) {
            self.viewModel.requestEnterText()
            stubResult.subject.onNext("title")
        }
        
        // then
        XCTAssertEqual(title, "title")
    }
    
    // 장소 입력 -> 주소 업데이트
    func testViewModel_afterEnterLocation_updateAddress() {
        // given
        let expect = expectation(description: "장소 입력 이후에 주소 업데이트")
        let stubResult = self.stubSelectLocation()
        
        self.viewModel.showup()
        
        // when
        let address = self.waitFirstElement(expect, for: self.viewModel.placeAddress) {
            self.viewModel.requestSelectPosition()
            var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
            location.placeMark = .init(address: "addr")
            stubResult.subject.onNext(location)
        }
        
        // then
        XCTAssertEqual(address, "addr")
    }
    
    // 장소 입력 완료시에 지도 노출
    func testViewModel_afterEnterLocation_updatePosition() {
        // given
        let expect = expectation(description: "장소 입력 이후에 위치 업데이트")
        let stubResult = self.stubSelectLocation()
        
        // when
        let location = self.waitFirstElement(expect, for: self.viewModel.placeLocation) {
            self.viewModel.requestSelectPosition()
            var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
            location.placeMark = .init(address: "addr")
            stubResult.subject.onNext(location)
        }
        
        // then
        XCTAssertNotNil(location)
    }
    
    // 태그 입력 -> 태그목록 업데이트
    func testViewModel_afterEnterTag_update() {
        // given
        let expect = expectation(description: "태그 입력 이후에 업데이트")
        
        let stubResult = StubSelectTagScenePresenter()
        self.spyRouter.register(type: SelectTagSceneOutput.self,
                                key: "openTagSelectScene") {
            return stubResult
        }
        
        // when
        let tags = self.waitFirstElement(expect, for: self.viewModel.selectedTags) {
            self.viewModel.requestEnterCategoryTag()
            stubResult.subject.onNext([Tag(placeCat: "some", emoji: "🏄‍♂️")])
        }
        
        // then
        XCTAssertEqual(tags?.count, 1)
    }
}

extension ManuallyResigterPlaceViewModelTests {
    
    private func stubAndEnterRequireInfos() {
        let stubTitleResult = self.stubEnterText()
        let stubLocationResult = self.stubSelectLocation()
        
        self.viewModel.requestEnterText()
        stubTitleResult.subject.onNext("some")
        
        self.viewModel.requestSelectPosition()
        var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
        location.placeMark = .init(address: "addr")
        stubLocationResult.subject.onNext(location)
    }
    
    // 이름 + 장소 입력 되어있으면 등록버튼 활성화
    func testViewModel_enableRegistable_whenTitleAndAddressEntered() {
        // given
        let expect = expectation(description: "이름과 장소가 입력되었을때 등록버튼 활성화")
        expect.expectedFulfillmentCount = 2
        
        // when
        let isRegistables = self.waitElements(expect, for: self.viewModel.isRegistable) {
            self.stubAndEnterRequireInfos()
        }
        
        // then
        XCTAssertEqual(isRegistables, [false, true])
    }
    
    func testViewModel_savePendingInput() {
        // given
        let expect = expectation(description: "입력중이던 정보 저장")
        
        let stubTitleResult = self.stubEnterText()
        
        self.stubRegisterUsecase.called(key: "finishInputPlaceInfo") { _ in
            expect.fulfill()
        }
        
        // when
        self.viewModel.requestEnterText()
        stubTitleResult.subject.onNext("some")
        self.viewModel.savePendingInput()
        
        // then
        self.wait(for: [expect], timeout: self.timeout)
    }
    
    // 등록 요청 -> 새로운 장소 방출
    func testViewModel_registerNewPlace() {
        // given
        let expect = expectation(description: "장소 저장 이후 새로운 장소 이벤트 방출")
        
        self.stubRegisterUsecase.register(key: "uploadNewPlace") {
            return Maybe<Place>.just(.dummy(0))
        }
        
        // when
        let newPlace = self.waitFirstElement(expect, for: self.viewModel.newPlace) {
            self.stubAndEnterRequireInfos()
            self.viewModel.requestRegister()
        }
        
        // then
        XCTAssertNotNil(newPlace)
    }
}


extension ManuallyResigterPlaceViewModelTests {
    
    class SpyRouter: ManuallyResigterPlaceRouting, Stubbable {
        
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
    
    class StubTextInputScenePresenter: TextInputSceneOutput {
        let subject = PublishSubject<String>()
        var enteredText: Observable<String> {
            return self.subject.asObservable()
        }
    }
    
    class StubLocationSelectScenePresenter: LocationSelectSceneOutput {
        let subject = PublishSubject<CurrentPosition>()
        var selectedLocation: Observable<CurrentPosition> {
            return self.subject.asObservable()
        }
    }
    
    class StubSelectTagScenePresenter: SelectTagSceneOutput {
        let subject = PublishSubject<[Tag]>()
        var selectedTags: Observable<[Tag]> {
            return subject.asObservable()
        }
    }
}
