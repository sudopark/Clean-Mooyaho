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
    
    public func fetchLatestHoorays(for memberID: String, limit: Int) -> Maybe<[Hooray]> {
        return self.dataModelStorage?.fetchLatestHoorays(for: memberID, limit: limit) ?? .empty()
    }
    
    public func saveHoorays(_ hoorays: [Hooray]) -> Maybe<Void> {
        return self.dataModelStorage?.saveHoorays(hoorays) ?? .empty()
    }
    
    public func fetchHoorays(_ ids: [String]) -> Maybe<[Hooray]> {
        return self.dataModelStorage?.fetchHoorays(ids) ?? .empty()
    }
    
    public func saveHoorayDetail(_ detail: HoorayDetail) -> Maybe<Void> {
        return self.dataModelStorage?.saveHoorayDetail(detail) ?? .empty()
    }
    
    public func fetchHoorayDetail(_ id: String) -> Maybe<HoorayDetail?> {
        return self.dataModelStorage?.fetchHoorayDetail(id) ?? .empty()
    }
}
