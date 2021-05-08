//
//  Reomte.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


// MARK: - Remote Error + Request Parameter Models

public enum RemoteErrors: Error {
    
    case operationFail(_ reason: Error?)
    case secretSignInFail(_ reason: Error?)
    case notSupportCredential(_ type: String)
    case loadFail(_ type: String, reason: Error?)
    case saveFail(_ type: String, reason: Error?)
    case mappingFail(_ type: String)
}


public enum ReqParams {
    
    public struct OAuthCredential {
        public init() {}
    }
    
    public typealias UserLocation = Domain.UserLocation
}


// MARK: - Remote Protocol

public protocol Remote: AuthRemote, PlaceRemote { }

// MARK: - Auth remote

public protocol AuthRemote {
    
    func requestSignInAnonymously() -> Maybe<Void>
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<DataModels.Member>
    
    func requestSignIn(using credential: ReqParams.OAuthCredential) -> Maybe<DataModels.Member>
}


// MARK: - place remote

public protocol PlaceRemote {
    
    func requesUpload(_ location: ReqParams.UserLocation) -> Maybe<Void>
    
    func requestLoadDefaultPlaceSuggest(in location: ReqParams.UserLocation) -> Maybe<DataModels.SuggestPlaceResult>
    
    func requestSuggestPlace(_ query: String,
                             in location: ReqParams.UserLocation,
                             cursor: String?) -> Maybe<DataModels.SuggestPlaceResult>
    
    func requestSearchNewPlace(_ query: String, in location: ReqParams.UserLocation,
                               of pageIndex: Int?) -> Maybe<DataModels.SearchingPlaceCollection>
}
