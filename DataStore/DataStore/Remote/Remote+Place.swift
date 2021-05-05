//
//  Remote+Place.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

public protocol PlaceRemote {
    
    func requesUpload(_ location: ReqParams.UserLocation) -> Maybe<Void>
    
    func requestLoadDefaultPlaceSuggest(in location: ReqParams.UserLocation) -> Maybe<DataModels.SuggestPlaceResult>
    
    func requestSuggestPlace(_ query: String,
                             in location: ReqParams.UserLocation,
                             page: Int?) -> Maybe<DataModels.SuggestPlaceResult>
}
