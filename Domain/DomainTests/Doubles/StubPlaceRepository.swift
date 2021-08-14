//
//  StubPlaceRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/08/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubPlaceRepository: PlaceRepository {
    
    struct Scenario {
        var loadPlaceResult: Result<Place, Error> = .success(Place.dummy(0))
    }
    
    private let scenario: Scenario
    init(_ scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    func uploadLocation(_ location: UserLocation) -> Maybe<Void> {
        return .empty()
    }
    
    func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return .empty()
    }
    
    func requestSuggestPlace(_ query: String, in location: UserLocation, cursor: String?) -> Maybe<SuggestPlaceResult> {
        return .empty()
    }
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation, of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return .empty()
    }
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        return self.scenario.loadPlaceResult.asMaybe()
    }
    
    func fetchRegisterPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?> {
        let form = self.pendingPlaceForm.map {
            return (form: $0, time: Date())
        }
        return .just(form)
    }
    
    private var pendingPlaceForm: NewPlaceForm?
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        self.pendingPlaceForm = form
        return .just()
    }
    
    func requestRegister(newPlace form: NewPlaceForm) -> Maybe<Place> {
        return .empty()
    }
    
    func fetchPlace(for placeID: String) -> Maybe<Place?> {
        return .just(self.savedPlaceMap[placeID])
    }
    
    private var savedPlaceMap: [String: Place] = [:]
    func savePlace(_ place: Place) -> Maybe<Void> {
        self.savedPlaceMap[place.uid] = place
        return .just(())
    }
}
