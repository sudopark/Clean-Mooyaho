//
//  StubReadItemOptionsRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubReadItemOptionsRepository: ReadItemOptionsRepository {
    
    func fetchLastestsIsShrinkModeOn() -> Maybe<Bool> {
        return .just(true)
    }
    
    func updateIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void> {
        return .just()
    }
}
