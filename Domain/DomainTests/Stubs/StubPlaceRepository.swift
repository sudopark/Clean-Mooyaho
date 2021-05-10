//
//  StubLocationRepository.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class StubPlaceRepository: PlaceRepository, Stubbable {
    
    func uploadLocation(_ location: UserLocation) -> Maybe<Void> {
        self.verify(key: "uploadLocation", with: location)
        return self.resolve(key: "uploadLocation") ?? .empty()
    }
    
    func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.resolve(key: "reqeustLoadDefaultPlaceSuggest") ?? .empty()
    }
    
    func requestSuggestPlace(_ query: String,
                             in location: UserLocation,
                             cursor: String?) -> Maybe<SuggestPlaceResult> {
        if let error = self.resolve(Error.self, key: "requestSuggestPlace") {
            return .error(error)
        }
        
        let key = "requestSuggestPlace:\(query)-\(String(describing: cursor))"
        return self.resolve(key: key)
            ?? .empty()
    }
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        let key = "requestSearchNewPlace:\(query)-\(String(describing: pageIndex))"
        return self.resolve(key: key) ?? .empty()
    }
    
    func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?> {
        return self.resolve(key: "fetchRegisterPendingNewPlaceForm") ?? .empty()
    }
    
    func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        self.verify(key: "savePendingRegister")
        return self.resolve(key: "savePendingRegister") ?? .empty()
    }
    
    func requestUpload(newPlace form: NewPlaceForm) -> Maybe<Place> {
        return self.resolve(key: "requestUpload") ?? .empty()
    }
}
