//
//  ReadItemOptionsRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemOptionsRepository {
    
    func fetchLastestsIsShrinkModeOn() -> Maybe<Bool>
    
    func updateIsShrinkModeOn(_ newvalue: Bool) -> Maybe<Void>
}
