//
//  ReadRemindRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/10/23.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestLoadReminds(for itemIDs: [String]) -> Maybe<[ReadRemind]> {
        return .empty()
    }
    
    public func requestUpdateReimnd(_ remind: ReadRemind) -> Maybe<Void> {
        return .empty()
    }
    
    public func requestRemoveRemind(remindID: String) -> Maybe<Void> {
        return .empty()
    }
}
