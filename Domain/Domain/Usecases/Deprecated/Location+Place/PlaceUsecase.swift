//
//  PlaceUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/08/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics

// MARK: - PlaceUsecase

public protocol PlaceUsecase {
        
    func refreshPlace(_ placeID: String)
    
    func loadPlace(_ placeID: String) -> Maybe<Place>
    
    func place(_ placeID: String) -> Observable<Place>
}


// MARK: - PlaceUsecaseImple

public final class PlaceUsecaseImple: PlaceUsecase {
    
    private let placeRepository: PlaceRepository
    private let sharedStoreService: SharedDataStoreService
    
    public init(placeRepository: PlaceRepository,
                sharedStoreService: SharedDataStoreService) {
        self.placeRepository = placeRepository
        self.sharedStoreService = sharedStoreService
        
    }
    
    private let disposeBag = DisposeBag()
}


// MARK: - PlaceUsecaseImple input

extension PlaceUsecaseImple {
    
    public func refreshPlace(_ placeID: String) {
        
        self.loadPlace(placeID)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}


// MARK: - PlaceUsecaseImple output

extension PlaceUsecaseImple {
    
    public func loadPlace(_ placeID: String) -> Maybe<Place> {
        
        let updateStore: (Place) -> Void = { [weak self] place in
            self?.updatePlaceOnStore(place)
        }
        
        return self.placeRepository.requestLoadPlace(placeID)
            .do(onNext: updateStore)
    }
    
    public func place(_ placeID: String) -> Observable<Place> {
        
        let key = SharedDataKeys.placeMap.rawValue
        
        let checkCache: () -> Void = { [weak self] in
            self?.setupSharedPlaceFromCacheIfNeed(placeID)
        }
        
        return self.sharedStoreService
            .observeWithCache([String: Place].self, key: key)
            .compactMap{ $0?[placeID] }
            .do(onSubscribed: checkCache)
    }
    
    private func setupSharedPlaceFromCacheIfNeed(_ placeID: String) {
        let placeMap = self.sharedStoreService.fetch([String: Place].self, key: .placeMap) ?? [:]
        guard placeMap[placeID] == nil else { return }
        
        let updateStoreIfExists: (Place?) -> Void = { [weak self] place in
            guard let place = place else { return }
            self?.updatePlaceOnStore(place)
        }
        
        self.placeRepository.fetchPlace(for: placeID)
            .subscribe(onSuccess: updateStoreIfExists)
            .disposed(by: self.disposeBag)
    }
    
    private func updatePlaceOnStore(_ place: Place) {
        let storeKey = SharedDataKeys.placeMap.rawValue
        self.sharedStoreService.update([String: Place].self, key: storeKey) {
            return ($0 ?? [:]) |> key(place.uid) .~ place
        }
    }
}
