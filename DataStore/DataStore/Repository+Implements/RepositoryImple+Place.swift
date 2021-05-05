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


public protocol PlaceRepositoryDefImpleDependency: AnyObject {
    
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
                                    page: Int?) -> Maybe<SuggestPlaceResult> {
        return self.remote.requestSuggestPlace(query, in: location, page: page)
    }
}
