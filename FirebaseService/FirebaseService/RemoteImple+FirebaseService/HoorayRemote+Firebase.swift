//
//  HoorayRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/16.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple: HoorayRemote { }


// MARK: - load hoorays

extension FirebaseServiceImple {
    
    public func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?> {
        
        let collectionRef = self.fireStoreDB.collection(.hooray)
        let query = collectionRef
            .whereField("pid", isEqualTo: memberID)
            .order(by: "ts", descending: true)
            .limit(to: 1)
        
        return self.load(query: query).map{ $0.first }
    }
    
    public func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        
        let loadRecentIndexes = self.loadRecentHoorayIndexes()
        
        let thenLoadAllMatchingHoorays: ([HoorayIndex]) -> Maybe<[Hooray]>
        thenLoadAllMatchingHoorays = { [weak self] indexes in
            return self?.loadAllHoorays(indexes.map{ $0.hoorayID }) ?? .empty()
        }
        
        let filterByLocation: ([Hooray]) -> [Hooray] = { hoorays in
            let center2D = CLLocationCoordinate2D(latitude: location.latt, longitude: location.long)
            let radiusKilometers: Double = searchDistanceMeters / 1000
            return hoorays.withIn(kilometers: radiusKilometers, center2D: center2D)
        }
        
        return loadRecentIndexes
            .flatMap(thenLoadAllMatchingHoorays)
            .map(filterByLocation)
    }
    
    private func loadRecentHoorayIndexes() -> Maybe<[HoorayIndex]> {
        let collectionRef = self.fireStoreDB.collection(.hoorayIndex)
        let lowBoundTime = TimeStamp.now() - 10 * 60
        let query = collectionRef
            .whereField(HoorayMappingKey.timestamp.rawValue, isGreaterThanOrEqualTo: lowBoundTime)
        return self.load(query: query)
    }
    
    private func loadAllHoorays(_ hoorayIDs: [String]) -> Maybe<[Hooray]> {
        let collectionRef = self.fireStoreDB.collection(.hooray)
        let sections = hoorayIDs.slice(by: 10)
        let queries = sections.map { ids in
            return collectionRef.whereField(FieldPath.documentID(), in: ids)
        }
        return self.loadAll(queries: queries)
    }
}


// MARK: - publish new hooray

extension FirebaseServiceImple {
    
    public func requestPublishHooray(_ newForm: NewHoorayForm,
                                     withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return .empty()
    }
}
