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
    
    public func asOptional() -> Observable<Element?> {
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
