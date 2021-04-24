//
//  WaitObservableEvents.swift
//  BreadRoadAppTests
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import UnitTestHelpKit


protocol WaitObservableEvents: class {
    
    var disposeBag: DisposeBag! { get set }
}


extension WaitObservableEvents where Self: BaseTestCase {
    
    func waitElements<E>(_ expect: XCTestExpectation,
                         for observable: Observable<E>,
                         skip: Int = 0,
                         timeout: TimeInterval? = nil,
                         action: @escaping () -> Void) -> [E] {
        // given
        var elements = [E]()
        
        observable
            .skip(skip)
            .subscribe(onNext: { element in
                elements.append(element)
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        // when
        action()
        self.wait(for: [expect], timeout: timeout ?? self.timeout)
        
        // then
        return elements
    }
    
    func waitFirstElement<E>(_ expect: XCTestExpectation,
                             for observable: Observable<E>,
                             skip: Int = 0,
                             timeout: TimeInterval? = nil,
                             action: @escaping () -> Void) -> E? {
        // given
        // when + then
        return self.waitElements(expect, for: observable, skip: skip, timeout: timeout, action: action).first
    }
    
    func waitError<E>(_ expect: XCTestExpectation,
                      for observable: Observable<E>,
                      timeout: TimeInterval? = nil,
                      action: @escaping () -> Void) -> Error? {
        // given
        var occurError: Error?
        
        observable
            .subscribe(onError: { error in
                occurError = error
                expect.fulfill()
            })
            .disposed(by: self.disposeBag)
        
        // when
        action()
        self.wait(for: [expect], timeout: timeout ?? self.timeout)
        
        // then
        return occurError
    }
}



// TEST

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
