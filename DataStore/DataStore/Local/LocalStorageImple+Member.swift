//
//  LocalStorageImple+Member.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func updateCurrentMember(_ newValue: Member) -> Maybe<Void> {
        return .just()
    }
}
