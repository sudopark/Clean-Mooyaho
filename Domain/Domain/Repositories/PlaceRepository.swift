//
//  PlaceRepository.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

public typealias PendingRegisterNewPlaceForm = (form: NewPlaceForm, time: Date)

public protocol PlaceRepository: AnyObject {
    
    func uploadLocation(_ location: UserLocation) -> Maybe<Void>
    
    func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult>
    
    func requestSuggestPlace(_ query: String, in location: UserLocation, cursor: String?) -> Maybe<SuggestPlaceResult>
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection>
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place>
    
    func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?>
    
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void>
    
    func requestRegister(newPlace form: NewPlaceForm) -> Maybe<Place>
}
