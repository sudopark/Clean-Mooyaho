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
    
    public func fetchRegisterPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?> {
        return self.environmentStorage.fetchPendingNewPlaceForm(memberID)
    }
    
    public func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return self.environmentStorage.savePendingNewPlaceForm(form)
    }
    
    public func removePendingRegisterForm(_ memberID: String) -> Maybe<Void> {
        return self.environmentStorage.removePendingNewPlaceForm(memberID)
    }
    
    public func savePlace(_ place: Place) -> Maybe<Void> {
        return self.dataModelStorage?.savePlace(place) ?? .empty()
    }
    
    public func fetchPlace(_ placeID: String) -> Maybe<Place?> {
        return self.dataModelStorage?.fetchPlace(placeID) ?? .empty()
    }
}