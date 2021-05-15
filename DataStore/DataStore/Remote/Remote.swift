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
    case invalidRequest(_ reason: String?)
}


public enum ReqParams {
    
    public struct OAuthCredential {
        public init() {}
    }
    
    public typealias UserLocation = Domain.UserLocation
    
    public typealias Tag = Domain.Tag
}


// MARK: - Remote Protocol

public protocol Remote: AuthRemote, PlaceRemote, TagRemote { }

// MARK: - Auth remote

public protocol AuthRemote {
    
    func requestSignInAnonymously() -> Maybe<DataModels.Auth>
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<DataModels.SigninResult>
    
    func requestSignIn(using credential: ReqParams.OAuthCredential) -> Maybe<DataModels.SigninResult>
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


// MARK: - Tag remote

public protocol TagRemote {
    
    func requestRegisterTag(_ tag: ReqParams.Tag) -> Maybe<Void>
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<DataModels.SuggestTagResultCollection>
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<DataModels.SuggestTagResultCollection>
}
