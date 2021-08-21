//
//  NearbyViewModelTests.swift
//  LocationScenesTests
//
//  Created by sudo.park on 2021/05/23.
//

import XCTest

import RxSwift
import Overture

import Domain
import UnitTestHelpKit
import UsecaseDoubles

@testable import MapScenes


class NearbyViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockLocationUsecase: MockUserLocationUsecase!
    var mockMemberUsecase: MockMemberUsecase!
    var spyRouter: SpyRouter!
    var viewModel: NearbyViewModel!
    
    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.mockLocationUsecase = .init()
        self.mockMemberUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = NearbyViewModelImple(locationUsecase: self.mockLocationUsecase,
                                              hoorayUsecase: MockHoorayUsecase(),
                                              memberUsecase: self.mockMemberUsecase,
                                              router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockLocationUsecase = nil
        self.mockMemberUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension NearbyViewModelTests {
    
    func testViewModel_whenHasNoAuthorixed_moveCameraToDefaultLocation() {
        // given
        let expect = expectation(description: "최초에 권한여부 조회해서 승인받지 않은 상태라면 디폴트위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.rejected)
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.moveCamera) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .coordinate = moving?.center {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    func testViewModel_whenAuthorizeStatusNotDetermied_requestAndGranted_moveCameraToCurrentPosition() {
        // given
        let expect = expectation(description: "권한 아직 판단 안되었으면 요청하고 승인 -> 현재 위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(true)
        }
        self.mockLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.moveCamera) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .coordinate = moving?.center {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    // 요청 완료 이후에 거절시 에러
    func testViewModel_whenAuthorizeStatusNotDetermied_requestAndRejected_moveCameraToDefaultPosition() {
        // given
        let expect = expectation(description: "권한 아직 판단 안되었으면 요청하고 거절 -> 디폴트 위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.moveCamera) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .coordinate = moving?.center {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    func testViewModel_whenAuthorizeStatusNotDetermied_requestAndRejected_alertUnavailToUseService() {
        // given
        let expect = expectation(description: "권한 아직 판단 안되었으면 요청하고 거절 -> 서비스 사용 불가 알림")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        let void: Void? = self.waitFirstElement(expect, for: self.viewModel.alertUnavailToUseService) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testViewModel_whenAuthorizeStatusAlreadyRejected_moveCameraToDefaultLocation() {
        // given
        let expect = expectation(description: "권한 이미 거절했으면 -> 디폴트 위치로 카메라 이동")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.rejected)
        }
        
        // when
        let moving = self.waitFirstElement(expect, for: self.viewModel.moveCamera) {
            self.viewModel.preparePermission()
        }
        
        // then
        if case .coordinate = moving?.center {
            XCTAssert(true)
        } else {
            XCTFail("기대하는 카메라 위치가 아님")
        }
    }
    
    func testViewModel_whenAuthorizeStatusAlreadyRejected_alertUnavailToUseService() {
        // given
        let expect = expectation(description: "권한 이미 거절했으면 -> 서비스 이용 불가 알림")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.rejected)
        }
        
        // when
        let void: Void? = self.waitFirstElement(expect, for: self.viewModel.alertUnavailToUseService) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertNotNil(void)
    }
    
    func testViewModel_whenAuthorizeStatusRejected_emitEvent() {
        // given
        let expect = expectation(description: "권한 거절시에 서비스 이용불가 외부로 알림")
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.notDetermined)
        }
        self.mockLocationUsecase.register(key: "requestPermission") {
            return Maybe<Bool>.just(false)
        }
        
        // when
        let void: Void? = self.waitFirstElement(expect, for: self.viewModel.alertUnavailToUseService) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertNotNil(void)
    }
}


// MARK: - interact with hooray usecase

class HoorayNearbyViewModelTests: NearbyViewModelTests {
    
    private var stubHoorayUsecase: BaseStubHoorayUsecase!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        self.viewModel = self.makeViewModel()
    }
    
    override func tearDownWithError() throws {
        self.stubHoorayUsecase = nil
        self.viewModel = nil
    }
    
    private func makeViewModel(shouldLoadHoorayFail: Bool = false,
                               recentNearbyHoorays: [Hooray]? = nil) -> NearbyViewModel {
        
        var scenario = BaseStubHoorayUsecase.Scenario()
        shouldLoadHoorayFail.then {
            scenario.loadHoorayResult = .failure(ApplicationErrors.invalid)
        }
        recentNearbyHoorays.whenExists {
            scenario.nearbyRecentHoorays = .success($0)
        }
        self.stubHoorayUsecase = .init(scenario)
        
        return NearbyViewModelImple(locationUsecase: self.mockLocationUsecase,
                                    hoorayUsecase: self.stubHoorayUsecase,
                                    memberUsecase: self.mockMemberUsecase,
                                    router: self.spyRouter)
    }
}

extension HoorayNearbyViewModelTests {
    
    func testViewModel_whenAfterNewHoorayPublished_addHoorayMarkerAndStartAnimation() {
        // given
        let expect = expectation(description: "신규 후레이 발급 이후에 후레이 마커 추가")
        
        // when
        let marker = self.waitFirstElement(expect, for: viewModel.newHooray) {
            let form = NewHoorayForm(publisherID: "some")
            self.stubHoorayUsecase.publish(newHooray: form, withNewPlace: nil)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        // then
        XCTAssertNotNil(marker)
        XCTAssertEqual(marker?.withFocusAnimation, true)
    }
    
    func testViewModel_receiveNewHooray() {
        // given
        let expect = expectation(description: "신규 후레이 수신 이후에 후레이 마커 추가")
        
        // when
        let marker = self.waitFirstElement(expect, for: viewModel.newHooray) {
            let dummyHooray = Hooray.dummy(0)
            let message = NewHoorayMessage(new: dummyHooray)
            self.stubHoorayUsecase.mockNewHooray.onNext(message)
        }
        
        // then
        XCTAssertNotNil(marker)
        XCTAssertEqual(marker?.withFocusAnimation, false)
    }
    
    func testViewModel_whenAfterLoadCoordinate_loadNearbyRecentHoorays() {
        // given
        let expect = expectation(description: "현재위치 로드 이후에 최근 근처 후레이 조회")
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.granted)
        }
        self.mockLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        
        // when
        let markers = self.waitFirstElement(expect, for: self.viewModel.recentNearbyHoorays) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertEqual(markers?.count, 1)
        XCTAssertEqual(markers?.first?.withFocusAnimation, false)
    }
    
    func testViewModel_whenReceiveNewHoorayMessageButLoadHoorayFail_ignore() {
        // given
        let expect = expectation(description: "신규 후레이 메세지는 수신했지만 조회 실패시 무시")
        expect.isInverted = true
        self.viewModel = self.makeViewModel(shouldLoadHoorayFail: true)
        
        // when
        let marker = self.waitFirstElement(expect, for: viewModel.newHooray) {
            let dummyHooray = Hooray.dummy(0)
            let message = NewHoorayMessage(new: dummyHooray)
            self.stubHoorayUsecase.mockNewHooray.onNext(message)
        }
        
        // then
        XCTAssertNil(marker)
    }
    
    func testViewModel_provideHoorayMarkerImageInfo() {
        // given
        let expect = expectation(description: "후레이 마커이미지 정보 제공")
        let hoorayWithImage = update(Hooray.dummy(0)) { $0.image = .path("some") }
        let hoorayWithOutImage = update(Hooray.dummy(1)) { $0.image = nil }
        let hoorayWithoutImageAndProfileIcon = update(Hooray.dummy(2)) { $0.image = nil }
        self.viewModel = self.makeViewModel(recentNearbyHoorays: [
            hoorayWithImage, hoorayWithOutImage, hoorayWithoutImageAndProfileIcon
        ])
        
        self.mockLocationUsecase.register(key: "checkHasPermission") {
            return Maybe<LocationServiceAccessPermission>.just(.granted)
        }
        self.mockLocationUsecase.register(key: "fetchUserLocation") {
            return Maybe<LastLocation>.just(.init(lattitude: 0, longitude: 0, timeStamp: 0))
        }
        self.mockMemberUsecase.register(type: Observable<[String: Member]>.self, key: "members:for") {
            let member1 = Member(uid: "pub:1", nickName: "m1", icon: .emoji("🎒"))
            let member2 = Member(uid: "pub:2", nickName: "m2", icon: nil)
            return .just([member1.uid: member1, member2.uid: member2])
        }
        
        // when
        let markerImageSource = Observable.combineLatest(
            self.viewModel.hoorayMarkerImage(hoorayWithImage.asMarker()),
            self.viewModel.hoorayMarkerImage(hoorayWithOutImage.asMarker()),
            self.viewModel.hoorayMarkerImage(hoorayWithoutImageAndProfileIcon.asMarker())
        )
        let images = self.waitFirstElement(expect, for: markerImageSource) {
            self.viewModel.preparePermission()
        }
        
        // then
        XCTAssertEqual(images?.0, .path("some"))
        XCTAssertEqual(images?.1, .emoji("🎒"))
        XCTAssertEqual(images?.2, .emoji("🤪"))
    }
}

extension NearbyViewModelTests {
    
    class SpyRouter: NearbyRouting { }
}

private extension Hooray {
    
    func asMarker() -> HoorayMarker {
        return .init(isNew: false, hoorayID: self.uid, publisherID: self.publisherID,
                     hoorayKeyword: self.hoorayKeyword, timeLabel: "\(self.timeStamp)",
                     removeAt: self.timeStamp + 10, message: self.message, image: self.image,
                     coordinate: self.location, spreadDistance: self.spreadDistance, aliveDuration: self.aliveDuration)
    }
}
