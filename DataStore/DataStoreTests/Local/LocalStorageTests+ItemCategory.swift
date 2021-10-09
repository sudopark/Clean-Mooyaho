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
    
    func testSaveAndFindCategories() {
        // given
        let expect = expectation(description: "이름으로 카테고리 조회")
        let dummies1 = (0..<10).map {
            return ItemCategory(name: "name-\($0)", colorCode: "some")
        }
        let dummies2 = (0..<10).map {
            return ItemCategory(name: "target-\($0)", colorCode: "some")
        }
        let dummies = dummies1 + dummies2
        
        // when
        let save = self.local.updateCategories(dummies)
        let find = self.local.suggestCategories("na")
        let saveAndFind = save.flatMap { _ in find }
        let categories = self.waitFirstElement(expect, for: saveAndFind.asObservable())
        
        // then
        XCTAssertEqual(categories?.map { $0.category }, dummies1)
    }
    
    func test_loadLatestCategories() {
        // given
        let expect = expectation(description: "최근 카테고리 - 최근에 저장된 순으로 조회")
        let dummies = self.dummyCategories
        
        // when
        let save = self.local.updateCategories(dummies)
        let load = self.local.loadLatestCategories()
        let saveAndLoad = save.flatMap { _ in load }
        let categories = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertEqual(categories?.map { $0.category.uid }, dummies.reversed().map { $0.uid })
    }
}
