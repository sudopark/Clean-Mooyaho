//
//  RepositoryImple+Place.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol PlaceRepositoryDefImpleDependency {
    
    var remote: PlaceRemote { get }
    var local: PlaceLocalStorage { get }
    var disposeBag: DisposeBag { get }
}

extension PlaceRepository where Self: PlaceRepositoryDefImpleDependency {
    
    public func uploadLocation(_ location: UserLocation) -> Maybe<Void> {
        return self.remote.requesUpload(location)
    }
    
    public func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.remote.requestLoadDefaultPlaceSuggest(in: location)
    }
    
    public func requestSuggestPlace(_ query: String,
                                    in location: UserLocation,
                                    cursor: String?) -> Maybe<SuggestPlaceResult> {
        return self.remote.requestSuggestPlace(query, in: location, cursor: cursor)
    }
    
    public func requestSearchNewPlace(_ query: String,
                                      in location: UserLocation,
                                      of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return self.remote.requestSearchNewPlace(query, in: location, of: pageIndex)
    }
    
    public func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        
        let updateLocalCache: (Place) -> Void = { [weak self] place in
            guard let self = self else { return }
            self.local.savePlaces([place])
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.remote.requestLoadPlace(placeID)
            .do(onNext: updateLocalCache)
    }
    
    public func fetchRegisterPendingNewPlaceForm() -> Maybe<PendingRegisterNewPlaceForm?> {
        return self.local.fetchRegisterPendingNewPlaceForm()
    }
    
    public func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return self.local.savePendingRegister(newPlace: form)
    }
    
    public func requestRegister(newPlace form: NewPlaceForm) -> Maybe<Place> {
        
        let saveAtLocal: (Place) -> Void = { [weak self] newPlace in
            guard let self = self else { return }
            self.local.savePlaces([newPlace])
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.remote.requestRegister(new: form)
            .do(onNext: saveAtLocal)
    }
}
