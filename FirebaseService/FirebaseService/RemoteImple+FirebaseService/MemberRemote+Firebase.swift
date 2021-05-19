//
//  MemberRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/20.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple: MemberRemote {
    
    public func requestUpdateUserPresence(_ userID: String, isOnline: Bool) -> Maybe<Void> {
        typealias Key = UserDeviceMappingKey
        let updating: JSON = [
            Key.isOnline.rawValue: isOnline
        ]
        return self.update(docuID: userID, newFields: updating, at: .userDevice)
    }
    
    public func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        // TOOD: implement needs
        return .empty()
    }
}
