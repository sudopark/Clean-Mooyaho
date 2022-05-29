//
//  LocalStorageTests+ReadingOption.swift
//  DataStoreTests
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ReadingOption: BaseLocalStorageTests { }


extension LocalStorageTests_ReadingOption {
    
    func testStorage_saveAndLoadLastReadPosition() {
        // given
        let expect = expectation(description: "저장된 읽기 위치 로드")
        // when
        let save = self.local.updateLastReadPosition(for: "some", 233)
        let saveAndLoad = save.flatMap { _ in
            self.local.fetchLastReadPosition(for: "some")
        }
        let position = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(position?.position, 233)
    }
    
    func testStorage_saveAndLoadReadPositionSaveOptionIsOn() {
        // given
        // when
        let isOnBeforeSave = self.local.isEnabledLastReadPositionSaveOption()
        self.local.updateEnableLastReadPositionSaveOption(false)
        let isOnAfterSave = self.local.isEnabledLastReadPositionSaveOption()
        
        // then
        XCTAssertEqual(isOnBeforeSave, true)
        XCTAssertEqual(isOnAfterSave, false)
    }
}
