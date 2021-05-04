//
//  WaitObservableEvents.swift
//  BreadRoadAppTests
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift


public protocol WaitObservableEvents: AnyObject {
    
    var disposeBag: DisposeBag! { get set }
}


extension WaitObservableEvents where Self: BaseTestCase {
    
    public func waitElements<E>(_ expect: XCTestExpectation,
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
    
    public func waitFirstElement<E>(_ expect: XCTestExpectation,
                                    for observable: Observable<E>,
                                    skip: Int = 0,
                                    timeout: TimeInterval? = nil,
                                    action: @escaping () -> Void) -> E? {
        // given
        // when + then
        return self.waitElements(expect, for: observable, skip: skip, timeout: timeout, action: action).first
    }
    
    public func waitFirstElement<E>(_ expect: XCTestExpectation,
                                    for observable: Observable<Optional<E>>,
                                    skip: Int = 0,
                                    timeout: TimeInterval? = nil,
                                    action: @escaping () -> Void) -> E? {
        return self.waitElements(expect, for: observable, skip: skip, timeout: timeout, action: action).first ?? nil
    }
    
    public func waitError<E>(_ expect: XCTestExpectation,
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
