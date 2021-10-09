//
//  LocalStorageTests+ItemCategory.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ItemCategory: BaseLocalStorageTests {
    
    private var dummyCategories: [ItemCategory] {
        return (0..<10).map {
            return ItemCategory(name: "n:\($0)", colorCode: "color")
        }
    }
}


extension LocalStorageTests_ItemCategory {
    
    func testSaveAndLoadCategories() {
        // given
        let expect = expectation(description: "카테고리 저장 이후에 로드")
        let dummies = self.dummyCategories
        
        // when
        let save = self.local.updateCategories(dummies)
        let load = self.local.fetchCategories(dummies.map { $0.uid } )
        let saveAndLoad = save.flatMap { _ in load }
        let categories = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(categories?.count, dummies.count)
    }
}
