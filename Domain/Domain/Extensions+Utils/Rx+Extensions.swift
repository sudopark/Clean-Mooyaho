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
