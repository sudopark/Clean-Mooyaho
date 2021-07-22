//
//  SelectTagViewModelImpleTests.swift
//  CommonPresentingTests
//
//  Created by sudo.park on 2021/06/12.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import UsecaseDoubles

@testable import CommonPresenting


class SelectTagViewModelImpleTests: BaseTestCase, WaitObservableEvents {
    
    private var dummyTotal: [Tag] {
        return (0..<20).map{ Tag(placeCat: "tag:\($0)", emoji: "") }
    }
    
    var disposeBag: DisposeBag!
    var viewModel: SelectTagViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.viewModel = .init(startWith: [], total: self.dummyTotal, router: EmptyRouter())
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.viewModel = nil
    }
}


extension SelectTagViewModelImpleTests {
    
    func testViewModel_whenShowup_showTags() {
        // given
        let expect = expectation(description: "전체 태그목록 노출")
        
        // when
        let tags = self.waitFirstElement(expect, for: self.viewModel.cellViewModels)
        
        // then
        XCTAssertEqual(tags?.count, 20)
    }
    
    // 선택 토글
    func testViewModel_updateSelected() {
        // given
        let expect = expectation(description: "선택된 정보 업데이트")
        expect.expectedFulfillmentCount = 4
        
        // when
        let selectedList = self.waitElements(expect, for: self.viewModel.cellViewModels) {
            self.viewModel.toggleSelect(self.dummyTotal[1].asCVM())
            self.viewModel.toggleSelect(self.dummyTotal[2].asCVM())
            self.viewModel.toggleSelect(self.dummyTotal[2].asCVM())
        }
        
        // then
        XCTAssertEqual(selectedList.map{ $0.selectedKeywords }, [
            [],
            [self.dummyTotal[1].keyword],
            [self.dummyTotal[1].keyword, self.dummyTotal[2].keyword],
            [self.dummyTotal[1].keyword]
        ])
    }
    
    // 확인시에 선택된 태그 방출
    func testViewModel_whenConfirm_emitSelectedTags() {
        // given
        let expect = expectation(description: "선택 확인시에 선택된 태그 방출")
        
        // when
        let selectedTags = self.waitFirstElement(expect, for: self.viewModel.selectedTags) {
            self.viewModel.toggleSelect(self.dummyTotal[1].asCVM())
            self.viewModel.toggleSelect(self.dummyTotal[2].asCVM())
            self.viewModel.confirmSelect()
        }
        
        // then
        XCTAssertEqual(selectedTags?.count, 2)
    }
}


extension SelectTagViewModelImpleTests {
    
    class EmptyRouter: SelectTagRouting, Mocking {
        
        func closeScene(animated: Bool, completed: (() -> Void)?) {
            completed?()
        }
    }
}


private extension Array where Element == TagCellViewModel {
    
    var selectedKeywords: [String] {
        return self.filter{ $0.isSelected }.map{ $0.keyword }
    }
}

private extension Tag {
    
    func asCVM() -> TagCellViewModel {
        return .init(tag: self)
    }
}
