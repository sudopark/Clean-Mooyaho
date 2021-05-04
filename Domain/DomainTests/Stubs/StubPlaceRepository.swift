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
    
    func requestSuggestPlace(_ query: String, in location: UserLocation, page: Int?) -> Maybe<SuggestPlaceResult> {
        
        if let error = self.resolve(Error.self, key: "requestSuggestPlace") {
            return .error(error)
        }
        
        return self.resolve(key: "requestSuggestPlace:\(query)-\(String(describing: page))")
            ?? .empty()
    }
}
