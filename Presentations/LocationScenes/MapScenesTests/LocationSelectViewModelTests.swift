//
//  LocationSelectViewModelTests.swift
//  LocationScenesTests
//
//  Created by sudo.park on 2021/07/04.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

@testable import MapScenes


class LocationSelectViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var mockUsecase: MockUserLocationUsecase!
    var viewModel: LocationSelectViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.mockUsecase = .init()
        self.viewModel = .init(nil, throttleInterval: 0,
                               userLocationUsecase: self.mockUsecase, router: SpyRouter())
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.mockUsecase = nil
        self.viewModel = nil
    }
}

extension LocationSelectViewModelTests {
    
    func testViewModel_whenPlaceSelected_updateIsConfirmable() {
        // given
        let expect = expectation(description: "장소선택 여부에 따라 선택가능 여부 업데이트")
        expect.expectedFulfillmentCount = 2
        
        // when
        let flags = self.waitElements(expect, for: self.viewModel.isConfirmable) {
            self.viewModel.selectCurrentLocation(.init(latt: 0, long: 0))
        }
        
        // then
        XCTAssertEqual(flags, [false, true])
    }
    
    func testViewModel_whenEditAddress_updateIsConfirmable() {
        // given
        let expect = expectation(description: "주소 수정여부에 따라 선택가능여부 업데이트")
        expect.expectedFulfillmentCount = 3
        
        // when
        let flags = self.waitElements(expect, for: self.viewModel.isConfirmable) {
            self.viewModel.selectCurrentLocation(.init(latt: 0, long: 0))
            self.viewModel.updateAddress("")
        }
        
        // then
        XCTAssertEqual(flags, [false, true, false])
    }
}


extension LocationSelectViewModelTests {
    
    class SpyRouter: LocationSelectRouting, Mocking { }
}
