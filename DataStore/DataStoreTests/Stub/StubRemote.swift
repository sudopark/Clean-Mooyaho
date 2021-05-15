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
    func requestSignInAnonymously() -> Maybe<DataModels.Auth> {
        self.verify(key: "requestSignInAnonymously")
        return self.resolve(key: "requestSignInAnonymously") ?? .empty()
    }
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<DataModels.SigninResult> {
        return self.resolve(key: "requestSignIn:withEmail") ?? .empty()
    }
    
    func requestSignIn(using credential: ReqParams.OAuthCredential) -> Maybe<DataModels.SigninResult> {
        return self.resolve(key: "requestSignIn:credential") ?? .empty()
    }
    
    // place
    func requesUpload(_ location: ReqParams.UserLocation) -> Maybe<Void> {
        return self.resolve(key: "requesUpload:location") ?? .empty()
    }
    
    func requestLoadDefaultPlaceSuggest(in location: ReqParams.UserLocation) -> Maybe<DataModels.SuggestPlaceResult> {
        return self.resolve(key: "requestLoadDefaultPlaceSuggest") ?? .empty()
    }
    
    func requestSuggestPlace(_ query: String,
                             in location: ReqParams.UserLocation,
                             cursor: String?) -> Maybe<DataModels.SuggestPlaceResult> {
        return self.resolve(key: "requestSuggestPlace") ?? .empty()
    }
    
    func requestSearchNewPlace(_ query: String, in location: ReqParams.UserLocation,
                               of pageIndex: Int?) -> Maybe<DataModels.SearchingPlaceCollection> {
        return self.resolve(key: "requestSearchNewPlace") ?? .empty()
    }
    
    // tag
    func requestRegisterTag(_ tag: ReqParams.Tag) -> Maybe<Void> {
        return self.resolve(key: "requestRegisterTag") ?? .empty()
    }
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<DataModels.SuggestTagResultCollection> {
        return self.resolve(key: "requestLoadPlaceCommnetTags") ?? .empty()
    }
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<DataModels.SuggestTagResultCollection> {
        return self.resolve(key: "requestLoadUserFeelingTags") ?? .empty()
    }
}
