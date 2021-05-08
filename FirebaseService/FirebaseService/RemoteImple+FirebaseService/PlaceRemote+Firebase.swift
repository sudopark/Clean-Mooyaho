//
//  PlaceRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/07.
//

import Foundation

import RxSwift

import DataStore


extension FirebaseServiceImple: PlaceRemote {
    
    
    public func requesUpload(_ location: ReqParams.UserLocation) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let db = self?.fireStoreDB else { return Disposables.create() }
            let documentRef = db.collection(.userLocation).document(location.userID)
            documentRef.setData(location.asJSON()) { error in
                if let error = error {
                    callback(.error(error))
                } else {
                    callback(.success(()))
                }
            }
            return Disposables.create()
        }
    }
    
    public func requestLoadDefaultPlaceSuggest(in location: ReqParams.UserLocation) -> Maybe<DataModels.SuggestPlaceResult> {
        return .empty()
    }
    
    public func requestSuggestPlace(_ query: String,
                                    in location: ReqParams.UserLocation,
                                    cursor: String?) -> Maybe<DataModels.SuggestPlaceResult> {
        return .empty()
    }
    
    public func requestSearchNewPlace(_ query: String,
                                      in location: ReqParams.UserLocation,
                                      of pageIndex: Int?) -> Maybe<DataModels.SearchingPlaceCollection> {
        let endpoint = NaverMapPlaceAPIEndPoint.places
        var params: [String: Any] = [:]
        params["query"] = query
        params["coords"] = [location.lastLocation.lattitude, location.lastLocation.longitude]
        params["page"] = pageIndex
        
        typealias ResultCollection = DataModels.SearchingPlaceCollection
        
        let appendQueryAtResult: (ResultCollection) -> (ResultCollection)
        appendQueryAtResult = { collection in
            var collection = collection
            collection.query = query
            return collection
        }
        
        return self.httpRemote
            .requestData(ResultCollection.self,
                         endpoint: endpoint, parameters: params)
            .map(appendQueryAtResult)
    }
}
