//
//  LocalStorageTests+ItemCategory.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/10/09.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_ItemCategory: BaseLocalStorageTests {
    
    private var dummyCategories: [ItemCategory] {
        return (0..<10).map {
            return ItemCategory(uid: "uid:\($0)", name: "n:\($0)",
                                colorCode: "color", createdAt: .now() - (10-$0).asTimeStamp())
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
        XCTAssertEqual(categories?.map { $0.category }.map { $0.uid }, dummies1.map { $0.uid })
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
    
    func testStorage_loadCategories_withPaging() {
        // given
        let expect = expectation(description: "카테고리 페이징과함꼐 생성시간 역순으로 조회")
        let dummies = self.dummyCategories
        
        // when
        let save = self.local.updateCategories(dummies)
        let load1 = self.local.fetchCategories(earilerThan: .now(), pageSize: 5)
        let thenLoad2AndMerge: ([ItemCategory]) -> Maybe<[ItemCategory]> = { cates in
            guard let last = cates.last else { return .just(cates) }
            return self.local.fetchCategories(earilerThan: last.createdAt, pageSize: 5)
                .map { cates + $0 }
        }
        let thenLoad3AndMerge: ([ItemCategory]) -> Maybe<[ItemCategory]> = { cates in
            guard let last = cates.last else { return .just(cates) }
            return self.local.fetchCategories(earilerThan: last.createdAt, pageSize: 5)
                .map { cates + $0 }
        }
        let saveAndLoadAll = save.flatMap{ load1 }.flatMap(thenLoad2AndMerge).flatMap(thenLoad3AndMerge)
        let items = self.waitFirstElement(expect, for: saveAndLoadAll.asObservable())
        
        // then
        let ids = items?.map { $0.uid }
        XCTAssertEqual(ids, dummies.reversed().map { $0.uid })
    }
    
    func testStorage_saveAndDeleteCategory() {
        // given
        let expect = expectation(description: "저장된 카테고리 삭제")
        let dummies = self.dummyCategories
        let target = dummies.randomElement()!
        
        // when
        let save = self.local.updateCategories(dummies)
        let delete = self.local.deleteCategory(target.uid)
        let load = self.local.fetchCategories(dummies.map { $0.uid })
        let saveDeleteAndLoad = save.flatMap { delete }.flatMap { load }
        let items = self.waitFirstElement(expect, for: saveDeleteAndLoad.asObservable())
        
        // then
        XCTAssertEqual(items?.count, dummies.count-1)
        XCTAssertEqual(items?.contains(where: { $0.uid == target.uid}), false)
    }
    
    func testStorage_findCategoryByName() {
        // given
        let expect = expectation(description: "이름으로 카테고리 찾기")
        let dummies = self.dummyCategories
        let target = dummies.randomElement()!
        
        // when
        let save = self.local.updateCategories(dummies)
        let find = self.local.findCategory(by: target.name)
        let saveAndFind = save.flatMap { find }
        let category = self.waitFirstElement(expect, for: saveAndFind.asObservable())
        
        // then
        XCTAssertNotNil(category)
    }
    
    func testStorage_updateCategoryByParams() {
        // given
        let expect = expectation(description: "파라미터로 카테고리 업데이트")
        let dummy = self.dummyCategories.first!
        let params = UpdateCategoryAttrParams(uid: dummy.uid)
            |> \.newName .~ "new name"
            |> \.newColorCode .~ "new color"
        
        // when
        let save = self.local.updateCategories([dummy])
        let update = self.local.updateCategory(by: params)
        let load = self.local.fetchCategories([dummy.uid])
        let saveUpdateAndLoad = save.flatMap { update }.flatMap { load }
        let category = self.waitFirstElement(expect, for: saveUpdateAndLoad.asObservable())
        
        // then
        XCTAssertEqual(category?.first?.name, "new name")
        XCTAssertEqual(category?.first?.colorCode, "new color")
    }
}
