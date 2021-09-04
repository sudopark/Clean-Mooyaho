//
//  BaseStubPlaceUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/08/14.
//

import Foundation

import RxSwift

import Domain


open class BaseStubPlaceUsecase: PlaceUsecase {
    
    
    public struct Scenario {
        
        public var placeResult: Result<Place, Error> = .success(Place.dummy(0))
        
        public init() { }
    }
    
    private let scenario: Scenario
    public init(_ scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    private let disposeBag = DisposeBag()
    private let placeMap = BehaviorSubject<[String: Place]>(value: [:])
    public func refreshPlace(_ placeID: String) {
        self.loadPlace(placeID)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func loadPlace(_ placeID: String) -> Maybe<Place> {
        
        return self.scenario.placeResult.asMaybe()
            .do(onNext: { place in
                var map = (try? self.placeMap.value()) ?? [:]
                map[placeID] = place
                self.placeMap.onNext(map)
            })
    }
    
    open func place(_ placeID: String) -> Observable<Place> {
        
        return self.placeMap
            .compactMap{ $0[placeID] }
    }
}
