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
    case notFound(_ type: String, reason: Error?)
}


// MARK: - Remote Protocol

public protocol Remote: AuthRemote, PlaceRemote, TagRemote { }

// MARK: - Auth remote

public protocol AuthRemote {
    
    func requestSignInAnonymously() -> Maybe<Auth>
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult>
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult>
}


// MARK: - place remote

public protocol PlaceRemote {
    
    func requesUpload(_ location: UserLocation) -> Maybe<Void>
    
    func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult>
    
    func requestSuggestPlace(_ query: String,
                             in location: UserLocation,
                             cursor: String?) -> Maybe<SuggestPlaceResult>
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection>
    
    func requestRegister(new place: NewPlaceForm) -> Maybe<Place>
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place>
}


// MARK: - Tag remote

public protocol TagRemote {
    
    func requestRegisterTag(_ tag: Tag) -> Maybe<Void>
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<SuggestTagResultCollection>
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<SuggestTagResultCollection>
}
