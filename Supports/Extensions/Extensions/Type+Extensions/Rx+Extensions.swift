//
//  Rx+Extensions.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

extension Observable {
    
    public func catchErrorAsEmpty() -> Observable {
        return self.catch{ _ in .empty() }
    }
    
    public func mapAsOptional() -> Observable<Element?> {
        return self.map { element -> Element? in
            return element
        }
    }
    
    public func ignoreError() -> Observable<Element> {
        return self.mapAsOptional().catchAndReturn(nil).compactMap{ $0 }
    }
}

extension Observable where Element == Void {
    
    public static func just() -> Observable<Element> {
        return .just(())
    }
}


extension Maybe where Element == Void {
    
    public static func just() -> Maybe<Element> {
        return .just(())
    }
}

extension PrimitiveSequenceType where Trait == MaybeTrait {
    
    public func mapAsOptional() -> Maybe<Element?> {
        return self.map{ element -> Element? in element }
    }
    
    public func ignoreError() -> Maybe<Element> {
        return self.mapAsOptional().catchAndReturn(nil).compactMap{ $0 }
    }
    
    public func switchOr(append secondary: @escaping () -> Maybe<Element>,
                         witoutError faillback: Element? = nil) -> Maybe<Element> {
        
        let appendIfNeed: (Element, Bool) -> Maybe<Element> = { element, isSwitched in
            guard isSwitched == false else { return .just(element) }
            return secondary()
                .catch { error in
                    guard let fallback = faillback else { throw error }
                    return .just(fallback)
                }
        }
        
        return self.map { ($0, false) }.ifEmpty(switchTo: secondary().map { ($0, true) })
            .flatMap(appendIfNeed)
    }
}


extension ObserverType where Element == Void {
    
    public func onNext() {
        self.onNext(())
    }
}


extension Result {
    
    public func asMaybe() -> Maybe<Success> {
        switch self {
        case let .success(value): return .just(value)
        case let .failure(error): return .error(error)
        }
    }
}


import RxRelay

extension PublishSubject: @unchecked Sendable { }
extension BehaviorSubject: @unchecked Sendable { }
extension PublishRelay: @unchecked Sendable { }
extension BehaviorRelay: @unchecked Sendable { }
extension DisposeBag: @unchecked Sendable { }
