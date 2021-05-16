//
//  StubRemote.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit

@testable import DataStore


class StubRemote: Remote, Stubbable {
    
    // auth
    func requestSignInAnonymously() -> Maybe<Auth> {
        self.verify(key: "requestSignInAnonymously")
        return self.resolve(key: "requestSignInAnonymously") ?? .empty()
    }
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult> {
        return self.resolve(key: "requestSignIn:withEmail") ?? .empty()
    }
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult> {
        return self.resolve(key: "requestSignIn:credential") ?? .empty()
    }
    
    // place
    func requesUpload(_ location: UserLocation) -> Maybe<Void> {
        return self.resolve(key: "requesUpload:location") ?? .empty()
    }
    
    func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.resolve(key: "requestLoadDefaultPlaceSuggest") ?? .empty()
    }
    
    func requestSuggestPlace(_ query: String,
                             in location: UserLocation,
                             cursor: String?) -> Maybe<SuggestPlaceResult> {
        return self.resolve(key: "requestSuggestPlace") ?? .empty()
    }
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return self.resolve(key: "requestSearchNewPlace") ?? .empty()
    }
    
    func requestRegister(new place: NewPlaceForm) -> Maybe<Place> {
        return self.resolve(key: "requestRegister:place") ?? .empty()
    }
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        return self.resolve(key: "requestLoadPlace") ?? .empty()
    }
    
    // tag
    func requestRegisterTag(_ tag: Tag) -> Maybe<Void> {
        return self.resolve(key: "requestRegisterTag") ?? .empty()
    }
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return self.resolve(key: "requestLoadPlaceCommnetTags") ?? .empty()
    }
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return self.resolve(key: "requestLoadUserFeelingTags") ?? .empty()
    }
    
    // hooray
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?> {
        return self.resolve(key: "requestLoadLatestHooray") ?? .empty()
    }
    
    func requestPublishHooray(_ newForm: NewHoorayForm,
                              withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return self.resolve(key: "requestPublishHooray") ?? .empty()
    }
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.resolve(key: "requestLoadNearbyRecentHoorays") ?? .empty()
    }
}
