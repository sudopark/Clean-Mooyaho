//
//  WaitObservableEventTests.swift
//  UnitTestHelpKitTests
//
//  Created by ParkHyunsoo on 2021/04/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

@testable import UnitTestHelpKit


class WaitObservableEventTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubSubject: PublishSubject<Int>!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = DisposeBag()
        self.stubSubject = .init()
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubSubject = nil
        super.tearDown()
    }
}

extension WaitObservableEventTests {
    
    private var waitingObservable: Observable<Int> {
        return self.stubSubject.asObservable()
    }
    
    func test_waitElements() {
        // given
        let expect = expectation(description: "여러개의 이벤트 대기")
        expect.expectedFulfillmentCount = 10
        
        // when
        let elements = self.waitElements(expect, for: self.waitingObservable) {
            (0..<10).forEach {
                self.stubSubject.onNext($0)
            }
        }
        
        // then
        XCTAssertEqual(elements, Array(0..<10))
    }
    
    func test_waitElementWithSkipFirst() {
        // given
        let expect = expectation(description: "처음 이벤트 제외 여러개의 이벤트 대기")
        expect.expectedFulfillmentCount = 9
        
        // when
        let elements = self.waitElements(expect, for: self.waitingObservable, skip: 1) {
            (0..<10).forEach {
                self.stubSubject.onNext($0)
            }
        }
        
        // then
        XCTAssertEqual(elements, Array(1..<10))
    }
    
    func test_firstElement() {
        // given
        let expect = expectation(description: "최초 이벤트 대기")
        
        // when
        let element = self.waitFirstElement(expect, for: self.waitingObservable) {
            self.stubSubject.onNext(1)
        }
        
        // then
        XCTAssertEqual(element, 1)
    }
    
    func test_firstElementWithSkipFirst() {
        // given
        let expect = expectation(description: "하나 거르고 최초 이벤트 대기")
        
        // when
        let element = self.waitFirstElement(expect, for: self.waitingObservable, skip: 1) {
            self.stubSubject.onNext(1)
            self.stubSubject.onNext(2)
        }
        
        // then
        XCTAssertEqual(element, 2)
    }
    
    func test_waitError() {
        // given
        let expect = expectation(description: "에러 대기")
        struct DummyError: Error {}
        
        // when
        let error = self.waitError(expect, for: self.waitingObservable) {
            self.stubSubject.onError(DummyError())
        }
        
        // then
        XCTAssert(error is DummyError)
    }
}
