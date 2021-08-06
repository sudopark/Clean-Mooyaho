//
//  AutoCompletable.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/08/07.
//

import Foundation

import RxSwift


@propertyWrapper
public class AutoCompletable<E> {
    
    private let subject: PublishSubject<E>
    
    public init(wrappedValue: PublishSubject<E>) {
        self.subject = wrappedValue
    }
    
    deinit {
        self.subject.onCompleted()
    }
    
    public init() {
        self.subject = .init()
    }
    
    public var wrappedValue: PublishSubject<E> {
        return self.subject
    }
}
