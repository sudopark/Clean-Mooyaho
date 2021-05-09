//
//  PlaceRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/07.
//

import Foundation

import RxSwift

import Domain
import DataStore


let searchDistanceMeters: Double = 50

extension FirebaseServiceImple: PlaceRemote {
    
    public func requesUpload(_ location: ReqParams.UserLocation) -> Maybe<Void> {
        
        return self.save(location, at: .userLocation)
    }
    
    public func requestLoadDefaultPlaceSuggest(in location: ReqParams.UserLocation) -> Maybe<DataModels.SuggestPlaceResult> {
        
        return self.suggestPlace(in: location, limit: 20)
    }
    
    
    // TODO: 페이징 지원 못함 -> limit없이 전체 불러오기
    public func requestSuggestPlace(_ query: String,
                                    in location: ReqParams.UserLocation,
                                    cursor: String?) -> Maybe<DataModels.SuggestPlaceResult> {
        
        return self.suggestPlace(keyword: query, in: location)
    }
    
    private func suggestPlace(keyword: String? = nil,
                              in location: ReqParams.UserLocation,
                              limit: Int? = nil) -> Maybe<DataModels.SuggestPlaceResult> {
        let collectionRef = self.fireStoreDB.collection(.placeSnippet)
        let (latt, long) = (location.lastLocation.lattitude, location.lastLocation.longitude)
        let center2D = CLLocationCoordinate2D(latitude: latt, longitude: long)
        let radiusKilometers: Double = searchDistanceMeters / 1000
        
        let queryBounds = GFUtils.queryBounds(forLocation: center2D, withRadius: radiusKilometers)
        
        let queries = queryBounds.map { bound -> Query in
            
            var query: Query
            if let keyword = keyword {
                query = collectionRef.whereField("title", isEqualTo: keyword)
                    .order(by: "geohash")
                    .order(by: "title")
            } else {
                query = collectionRef
                    .order(by: "geohash")
            }
            query = query
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
            
            if let limit = limit {
                query = query.limit(to: limit)
            }
            
            return query
        }
        
        let seed: Observable<[PlaceSnippet]> = .empty()
        let loadAllPlaces = queries.map{ query -> Maybe<[PlaceSnippet]> in
                return self.load(query: query)
            }
            .reduce(seed) { acc, next in
                return acc.asObservable().concat(next.asObservable())
            }
            .asMaybe()
        
        let then2ndFilterByDistance: ([PlaceSnippet]) -> [PlaceSnippet]
        then2ndFilterByDistance = { places in
            return places.withIn(kilometers: radiusKilometers, center2D: center2D)
        }
        
        let thenConvertToResult: ([PlaceSnippet]) -> DataModels.SuggestPlaceResult = { places in
            return .init(default: places)
        }
        
        return loadAllPlaces
            .map(then2ndFilterByDistance)
            .map(thenConvertToResult)
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
        
        return self.httpAPI
            .requestData(ResultCollection.self,
                         endpoint: endpoint, parameters: params)
            .map(appendQueryAtResult)
    }
}

private extension Array where Element == PlaceSnippet {
    
    func withIn(kilometers: Double, center2D: CLLocationCoordinate2D) -> [PlaceSnippet] {
        return self.compactMap { place -> PlaceSnippet? in
            let coordi = CLLocation(latitude: place.latt, longitude: place.long)
            let center = CLLocation(latitude: center2D.latitude, longitude: center2D.longitude)
            
            let distance = GFUtils.distance(from: center, to: coordi)
            guard distance <= kilometers else { return nil }
            return place
        }
    }
}
