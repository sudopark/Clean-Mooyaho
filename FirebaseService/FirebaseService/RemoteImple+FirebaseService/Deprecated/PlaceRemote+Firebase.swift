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


// MARK: - FirebaseServiceImple confirm PlaceRemote

extension FirebaseServiceImple {
    
    public func requesUpload(_ location: UserLocation) -> Maybe<Void> {
        
        return self.save(location, at: .userLocation)
    }
}


// MARK: - suggest places

extension FirebaseServiceImple {
    
    fileprivate typealias Keys = PlaceMappingKey

    public func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        
        return self.suggestPlace(in: location, limit: 20)
    }
    
    
    // TODO: 페이징 지원 못함 -> limit없이 전체 불러오기
    public func requestSuggestPlace(_ query: String,
                                    in location: UserLocation,
                                    cursor: String?) -> Maybe<SuggestPlaceResult> {
        
        return self.suggestPlace(keyword: query, in: location)
    }
    
    private func suggestPlace(keyword: String? = nil,
                              in location: UserLocation,
                              limit: Int? = nil) -> Maybe<SuggestPlaceResult> {
        let collectionRef = self.fireStoreDB.collection(.placeSnippet)
        let (latt, long) = (location.lastLocation.lattitude, location.lastLocation.longitude)
        let center2D = CLLocationCoordinate2D(latitude: latt, longitude: long)
        let radiusMeters: Meters = Policy.hoorayPublishRangeDistance
        
        func suggestByTitle(_ text: String) -> Maybe<[PlaceSnippet]> {
            
            let textEnd = "\(text)\u{F8FF}"
            var query = collectionRef
                .whereField(Keys.title.rawValue, isGreaterThanOrEqualTo: text)
                .whereField(Keys.title.rawValue, isLessThanOrEqualTo: textEnd)
            if let limit = limit {
                query = query.limit(to: limit)
            }
            
            return self.load(query: query)
        }
        
        func suggestByDistance() -> Maybe<[PlaceSnippet]> {
            let queryBounds = GFUtils.queryBounds(forLocation: center2D, withRadius: radiusMeters)
            let queries = queryBounds.map { bound -> Query in
                
                var query  = collectionRef
                        .order(by: Keys.geoHash.rawValue)
                        .start(at: [bound.startValue])
                        .end(at: [bound.endValue])
                
                if let limit = limit {
                    query = query.limit(to: limit)
                }
                
                return query
            }
            return self.loadAllAtOnce(queries: queries)
        }
        
        let then2ndFilterByDistance: ([PlaceSnippet]) -> [PlaceSnippet]
        then2ndFilterByDistance = { places in
            return places.withIn(meters: radiusMeters, center2D: center2D)
        }
        
        let thenConvertToResult: ([PlaceSnippet]) -> SuggestPlaceResult = { places in
            return .init(query: keyword ?? "", places: places, cursor: nil)
        }
        
        let loading = keyword.map(suggestByTitle(_:)) ?? suggestByDistance()
        
        return loading
            .map(then2ndFilterByDistance)
            .map(thenConvertToResult)
    }
    
    func loadNearby<T>(_ center: Coordinate, radius: Meters,
                       colletionRef: CollectionReference,
                       geoHaskKey: String = Keys.geoHash.rawValue) -> Maybe<[T]> where T: DocumentMappable {
        let center2D = CLLocationCoordinate2D(latitude: center.latt, longitude: center.long)
        let queryBounds = GFUtils.queryBounds(forLocation: center2D, withRadius: radius)
        let queries = queryBounds.map { bound -> Query in
            
            let query = colletionRef
                .order(by: geoHaskKey)
                .start(at: [bound.startValue])
                .end(at: [bound.endValue])
            
            return query
        }
        return self.loadAllAtOnce(queries: queries)
    }
    
    public func requestSearchNewPlace(_ query: String,
                                      in location: UserLocation,
                                      of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        let endpoint = NaverMapPlaceAPIEndPoint.places
        var params: [String: Any] = [:]
        params["query"] = query
        params["searchCoord"] = "\(location.lastLocation.longitude);\(location.lastLocation.lattitude)"
        params["page"] = pageIndex
        params["displayCount"] = 30
        
        typealias ResultCollection = SearchingPlaceCollection
        
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
    
    
    public func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        
        let loadPlace: Maybe<Place?> = self.load(docuID: placeID, in: .place)
        let throwErrorWhenNotExists: (Place?) throws -> Place = { place in
            guard let place = place else {
                let type = String(describing: Place.self)
                throw RemoteErrors.notFound(type, reason: nil)
            }
            return place
        }
        
        return loadPlace.map(throwErrorWhenNotExists)
    }
}


// MARK: - upload new place

extension FirebaseServiceImple {
    
    public func requestRegister(new place: NewPlaceForm) -> Maybe<Place> {
        
        let registerPlace: Maybe<Place> = self.saveNew(place, at: .place)
        
        let postRegisterActions: (Place) -> Void = { [weak self] newPlace in
            self?.saveSnippet(for: newPlace)
        }
        
        return registerPlace
            .do(onNext: postRegisterActions)
    }
    
    private func saveSnippet(for place: Place) {
        let snippet = PlaceSnippet(place: place)
        self.save(snippet, at: .placeSnippet)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}