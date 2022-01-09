//
//  ReadLinkMemoUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import UnitTestHelpKit

import Domain


class ReadLinkMemoUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
    }
    
    private func makeUsecase() -> ReadLinkMemoUsecase {
        
        let repository = StubReadLinkMemoRepository()
        return ReadLinkMemoUsecaseImple(repository: repository)
    }
}

extension ReadLinkMemoUsecaseTests {
    
    func testUsecase_loadMemo() {
        // given
        let expect = expectation(description: "memo 로드")
        let usecase = self.makeUsecase()
        
        // when
        let memo = self.waitFirstElement(expect, for: usecase.loadMemo(for: "soem"))
        
        // then
        XCTAssertNotNil(memo)
    }
    
    func testUsecase_updateMemeo() {
        // given
        let expect = expectation(description: "memo 수정")
        let usecase = self.makeUsecase()
        
        // when
        let editing = usecase.updateMemo(.dummyID("some"))
        let result: Void? = self.waitFirstElement(expect, for: editing.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
    
    func testUsecase_removeMemo() {
        // given
        let expect = expectation(description: "memo 삭제")
        let usecase = self.makeUsecase()
        
        // when
        let deleting = usecase.deleteMemo(for: "some")
        let result: Void? = self.waitFirstElement(expect, for: deleting.asObservable())
        
        // then
        XCTAssertNotNil(result)
    }
}
