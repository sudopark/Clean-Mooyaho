//
//  PlaceRepository.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol PlaceRepository {
    
    func uploadLocation(_ location: UserLocation) -> Maybe<Void>
    
    func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult>
    
    func requestSuggestPlace(_ query: String, in location: UserLocation, page: Int?) -> Maybe<SuggestPlaceResult>
}
