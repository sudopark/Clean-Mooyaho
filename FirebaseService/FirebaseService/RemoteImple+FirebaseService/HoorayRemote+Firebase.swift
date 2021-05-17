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
        return self.loadAllAtOnce(queries: queries)
    }
}


// MARK: - publish new hooray

extension FirebaseServiceImple {
    
    private func appendPlaceIDWithSaveIfNeed(_ hoorayForm: NewHoorayForm,
                                             placeForm: NewPlaceForm?) -> Maybe<NewHoorayForm> {
        switch placeForm {
        case let .some(form):
            return self.requestRegister(new: form).map{ hoorayForm.append($0.uid) }
            
        case .none where hoorayForm.placeID == nil:
            return .error(RemoteErrors.invalidRequest("no place id defined for newHooray"))
            
        default:
            return .just(hoorayForm)
        }
    }
    
    public func requestPublishHooray(_ newForm: NewHoorayForm,
                                     withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {

        let completeHoorayForm = self.appendPlaceIDWithSaveIfNeed(newForm, placeForm: withNewPlace)
        let thenSaveNewHoorayWithPlaceId: (NewHoorayForm) -> Maybe<Hooray> = { [weak self] form in
            return self?.saveNew(form, at: .hooray) ?? .empty()
        }
        let andSaveHoorayIndex: (Hooray) -> Maybe<Hooray> = { [weak self] hooray in
            guard let self = self else { return .empty() }
            let index = HoorayIndex(hid: hooray.uid, at: hooray.timeStamp)
            return self.save(index, at: .hoorayIndex).map{ _ in hooray }
        }
        
        let finallySendMessages: (Hooray) -> Void = { [weak self] hooray in
            self?.sendNewHoorayMessagesToNearbyUsers(hooray)
        }
        
        return completeHoorayForm
            .flatMap(thenSaveNewHoorayWithPlaceId)
            .flatMap(andSaveHoorayIndex)
            .do(onNext: finallySendMessages)
    }
    
    private func sendNewHoorayMessagesToNearbyUsers(_ newHooray: Hooray) {
        
        let thenLoadOnlineDevicesStream: ([String]) -> Observable<[UserDevices]>
        thenLoadOnlineDevicesStream = { [weak self] userIDs in
            guard let self = self else { return .empty() }
            typealias Key = UserDeviceMappingKey
            let colllectionRef = self.fireStoreDB.collection(.userDevice)
            let queries = userIDs.slice(by: 10).map {
                return colllectionRef
                    .whereField(FieldPath.documentID(), in: $0)
                    .whereField(Key.isOnline.rawValue, isEqualTo: true)
            }
            return self.loadAll(queries: queries)
        }
        
        let thenSendMessages: ([UserDevices]) -> Void = { [weak self] devices in
            // TODO: send messages
        }
        self.loadNearbyUserIDs(center: newHooray.location, radius: newHooray.spreadDistance)
            .asObservable()
            .flatMap(thenLoadOnlineDevicesStream)
            .subscribe(onNext: thenSendMessages)
            .disposed(by: self.disposeBag)
    }
    
    private func loadNearbyUserIDs(center: Coordinate, radius: Double) -> Maybe<[String]> {
        
        let collectionRef = self.fireStoreDB.collection(.userLocation)
        let radiusKilometer = radius / 1000
        let userLocations: Maybe<[UserLocation]> = self.loadNearby(center, radius: radius,
                                                                   colletionRef: collectionRef)
        return userLocations
            .map{ $0.map{ $0.userID } }
    }
}


private extension NewHoorayForm {
    
    func append(_ placeID: String) -> NewHoorayForm {
        self.placeID = placeID
        return self
    }
}
