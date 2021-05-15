//
//  RegisterNewPlaceUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/10.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol RegisterNewPlaceUsecase {
    
}


public struct ValidPendingRegisterNewPlacePolicy {
    
    public let maxDistance: Meters
    public let timeInterval: Minutes
    
    public init(distance: Meters, interval: Minutes) {
        self.maxDistance = distance
        self.timeInterval = interval
    }
    
    public static func `default`() -> Self {
        return .init(distance: 100, interval: 3 * 60)
    }
}

public final class RegisterNewPlaceUsecaseImple {
    
    private let placeRepository: PlaceRepository
    private let policy: ValidPendingRegisterNewPlacePolicy
    
    public init(placeRepository: PlaceRepository,
                validPendingPolicy: ValidPendingRegisterNewPlacePolicy = .default()) {
        self.placeRepository = placeRepository
        self.policy = validPendingPolicy
    }

    private let disposeBag = DisposeBag()
}

extension RegisterNewPlaceUsecaseImple {
    
    private static var validPendingInfoDistance: Meters {
        return 100
    }
    
    public func loadRegisterPendingNewPlaceForm(withIn position: Coordinate) -> Maybe<NewPlaceForm?> {
        
        let policy = self.policy
        let filteringByDistanceAndTime: (PendingRegisterNewPlaceForm?) -> NewPlaceForm?
        filteringByDistanceAndTime = { pendingForm in
            guard let pendingForm = pendingForm else { return nil }
            
            let distance = pendingForm.form.coordinate.distance(from: position)
            let isOutofRange = abs(distance) > policy.maxDistance
            let interval = Date().timeIntervalSince(pendingForm.time)
            let isTooLate = interval > policy.timeInterval.asTimeInterval()
            
            switch (isOutofRange, isTooLate) {
            case (false, _): return pendingForm.form
            case (true, false): return pendingForm.form
            default: return nil
            }
        }
        return self.placeRepository.fetchRegisterPendingNewPlaceForm()
            .map(filteringByDistanceAndTime)
    }
    
    public func finishInputPlaceInfo(_ form: NewPlaceForm) -> Maybe<NewPlaceForm> {
        
        return self.placeRepository.savePendingRegister(newPlace: form).map{ _ in form }
    }
    
    public func uploadNewPlace(_ form: NewPlaceForm) -> Maybe<Place> {

        return self.placeRepository.requestRegister(newPlace: form)
    }
}
