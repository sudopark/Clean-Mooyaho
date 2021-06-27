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
    
    public func saveMember(_ member: Member) -> Maybe<Void> {
        return self.dataModelStorage.save(member: member)
    }
    
    public func fetchMember(for memberID: String) -> Maybe<Member?> {
        
        return self.dataModelStorage.fetchMember(for: memberID)
    }
    
    public func updateCurrentMember(_ newValue: Member) -> Maybe<Void> {
        
        return self.dataModelStorage.updateMember(newValue)
    }
}
