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


class StubLocationRepository: LocationRepository, Stubbable {
    
    func uploadLocation(_ location: UserLocation) -> Maybe<Void> {
        self.verify(key: "uploadLocation", with: location)
        return self.resolve(key: "uploadLocation") ?? .empty()
    }
}
