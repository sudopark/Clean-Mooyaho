//
//  LocalStorageImple+ReadRemind.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchReadReminds(for itemsIDs: [String]) -> Maybe<[ReadRemind]> {
        return self.dataModelStorage.fetchReadReminds(for: itemsIDs)
    }
    
    public func updateReadRemind(_ remind: ReadRemind) -> Maybe<Void> {
        return self.dataModelStorage.updateReadRemind(remind)
    }
    
    public func removeReadRemind(for reminderID: String) -> Maybe<Void> {
        return self.dataModelStorage.removeReadRemind(for: reminderID)
    }
}
