//
//  RepositoryImple+Place.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol PlaceRepositoryDefImpleDependency {
    
    var remote: Remote { get }
}

extension PlaceRepository where Self: PlaceRepositoryDefImpleDependency {
    
    public func uploadLocation(_ location: UserLocation) -> Maybe<Void> {
        return self.remote.requesUpload(location)
    }
    
    public func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.remote.requestLoadDefaultPlaceSuggest(in: location)
    }
    
    public func requestSuggestPlace(_ query: String,
                                    in location: UserLocation,
                                    cursor: String?) -> Maybe<SuggestPlaceResult> {
        return self.remote.requestSuggestPlace(query, in: location, cursor: cursor)
    }
    
    public func requestSearchNewPlace(_ query: String,
                                      in location: UserLocation,
                                      of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return self.remote.requestSearchNewPlace(query, in: location, of: pageIndex)
    }
    
    
    public func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?> {
        return .empty()
    }
    
    public func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return .empty()
    }
    
    public func requestUpload(newPlace form: NewPlaceForm) -> Maybe<Place> {
        return .empty()
    }
}
