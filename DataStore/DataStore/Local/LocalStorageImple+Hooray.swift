//
//  LocalStorageImple+Hooray.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchLatestHooray(for memberID: String) -> Maybe<Hooray?> {
        return .just(nil)
    }
    
    public func fetchHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]> {
        return .empty()
    }
    
    public func saveHoorays(_ hooray: [Hooray]) -> Maybe<Void> {
        return .empty()
    }
}
