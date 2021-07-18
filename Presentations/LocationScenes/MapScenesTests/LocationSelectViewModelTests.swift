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

@testable import MapScenes


class LocationSelectViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var viewModel: LocationSelectViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.viewModel = .init(nil, router: SpyRouter())
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
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
            var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
            location.placeMark = .init(address: "some")
            self.viewModel.selectCurrentLocation(location)
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
            var location = CurrentPosition(lattitude: 0, longitude: 0, timeStamp: 0)
            location.placeMark = .init(address: "some")
            self.viewModel.selectCurrentLocation(location)
            
            self.viewModel.updateAddress("")
        }
        
        // then
        XCTAssertEqual(flags, [false, true, false])
    }
}


extension LocationSelectViewModelTests {
    
    class SpyRouter: LocationSelectRouting, Stubbable { }
}
