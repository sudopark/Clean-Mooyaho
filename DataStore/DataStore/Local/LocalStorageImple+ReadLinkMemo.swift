//
//  LocalStorageImple+ReadLinkMemo.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        return self.dataModelStorage.fetchMemo(for: linkItemID)
    }
    
    public func updateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        return self.dataModelStorage.updateMemo(newValue)
    }
    
    public func deleteMemo(for linkItemID: String) -> Maybe<Void> {
        return self.dataModelStorage.deleteMemo(for: linkItemID)
    }
}
