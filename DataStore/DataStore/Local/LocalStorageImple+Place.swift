//
//  LocalStorageImple+Place.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?> {
        return .empty()
    }
    
    public func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return .empty()
    }
    
    public func removePendingRegisterForm() -> Maybe<Void> {
        return .empty()
    }
    
    public func savePlaces(_ places: [Place]) -> Maybe<Void> {
        return .empty()
    }
}
