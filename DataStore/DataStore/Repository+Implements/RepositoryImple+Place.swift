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


public protocol PlaceRepositoryDefImpleDependency: AnyObject {
    
    var placeRemote: PlaceRemote { get }
    var placeLocal: PlaceLocalStorage { get }
    var disposeBag: DisposeBag { get }
}

extension PlaceRepository where Self: PlaceRepositoryDefImpleDependency {
    
    public func uploadLocation(_ location: UserLocation) -> Maybe<Void> {
        return self.placeRemote.requesUpload(location)
    }
    
    public func reqeustLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.placeRemote.requestLoadDefaultPlaceSuggest(in: location)
    }
    
    public func requestSuggestPlace(_ query: String,
                                    in location: UserLocation,
                                    cursor: String?) -> Maybe<SuggestPlaceResult> {
        return self.placeRemote.requestSuggestPlace(query, in: location, cursor: cursor)
    }
    
    public func requestSearchNewPlace(_ query: String,
                                      in location: UserLocation,
                                      of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return self.placeRemote.requestSearchNewPlace(query, in: location, of: pageIndex)
    }
    
    public func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        
        let updateLocalCache: (Place) -> Void = { [weak self] place in
            guard let self = self else { return }
            self.placeLocal.savePlace(place)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.placeRemote.requestLoadPlace(placeID)
            .do(onNext: updateLocalCache)
    }
    
    public func fetchRegisterPendingNewPlaceForm(_ memberID: String) -> Maybe<PendingRegisterNewPlaceForm?> {
        return self.placeLocal.fetchRegisterPendingNewPlaceForm(memberID)
    }
    
    public func savePendingRegister(newPlace form: NewPlaceForm) -> Maybe<Void> {
        return self.placeLocal.savePendingRegister(newPlace: form)
    }
    
    public func requestRegister(newPlace form: NewPlaceForm) -> Maybe<Place> {
        
        let saveAtLocal: (Place) -> Void = { [weak self] newPlace in
            guard let self = self else { return }
            self.placeLocal.savePlace(newPlace)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        let removePendingInput: (Place) -> Void = { [weak self] _ in
            guard let self = self else { return }
            self.placeLocal.removePendingRegisterForm(form.reporterID)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.placeRemote.requestRegister(new: form)
            .do(onNext: saveAtLocal)
            .do(onNext: removePendingInput)
    }
}
