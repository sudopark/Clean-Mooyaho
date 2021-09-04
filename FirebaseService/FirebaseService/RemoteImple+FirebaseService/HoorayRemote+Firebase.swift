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


extension FirebaseServiceImple { }


// MARK: - load hoorays

extension FirebaseServiceImple {
    
    public func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?> {
        
        typealias Mapkey = HoorayMappingKey
        
        let collectionRef = self.fireStoreDB.collection(.hooray)
        let query = collectionRef
            .whereField(Mapkey.publisherID.rawValue, isEqualTo: memberID)
            .order(by: Mapkey.timestamp.rawValue, descending: true)
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
            return hoorays.withIn(meters: { $0.spreadDistance }, center2D: center2D)
        }
        
        return loadRecentIndexes
            .flatMap(thenLoadAllMatchingHoorays)
            .map(filterByLocation)
    }
    
    private func loadRecentHoorayIndexes() -> Maybe<[HoorayIndex]> {
        let collectionRef = self.fireStoreDB.collection(.hoorayIndex)
        let lowBoundTime = TimeStamp.now() - Policy.recentHoorayTime
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
    
    public func requestAckHooray(_ acks: [HoorayAckMessage]) {
        
        typealias Key = HoorayMappingKey
        
        guard let myID = acks.first?.ackUserID else { return }
        let collectionRef = self.fireStoreDB.collection(.hoorayAcks)
        let query = collectionRef
            .whereField(Key.uid.rawValue, in: acks.map{ $0.hoorayID })
            .whereField(Key.ackUserID.rawValue, isEqualTo: myID)

        let newAcks = acks.map{ HoorayAckInfo(hoorayID: $0.hoorayID, ackUserID: $0.ackUserID, ackAt: .now()) }
        let loadAlreadyAcks: Maybe<[HoorayAckInfo]> = self.load(query: query)
        let filteringAcks: ([HoorayAckInfo]) -> [HoorayAckInfo] = { alreadyAcks in
            let alreadyIDSet = Set(alreadyAcks.map{ $0.hoorayID} )
            return newAcks.filter{ alreadyIDSet.contains($0.hoorayID) == false }
        }
        let thenSaveAcksAndSendMessages: ([HoorayAckInfo]) -> Void = { [weak self] newAcks in
            guard let self = self else { return }
            let savings = newAcks.map{ self.save($0, at: .hoorayAcks).subscribe() }
            self.disposeBag.insert(savings)
            
            let messages = acks.filter{ m in newAcks.contains(where: { $0.hoorayID == m.hoorayID }) }
            self.sendAckMessages(messages)
        }
        
        loadAlreadyAcks
            .map(filteringAcks)
            .subscribe(onSuccess: thenSaveAcksAndSendMessages)
            .disposed(by: self.disposeBag)
    }
    
    private func sendAckMessages(_ acks: [HoorayAckMessage]) {
        let sendings = acks.map{
            self.requestSendForground(message: $0, to: $0.hoorayPublisherID).subscribe()
        }
        self.disposeBag.insert(sendings)
    }
    
    public func requestLoadHooray(_ id: String) -> Maybe<Hooray?> {
        
        let collectionRef = self.fireStoreDB.collection(.hooray)
        let query = collectionRef.whereField(FieldPath.documentID(), isEqualTo: id)
        
        return self.load(query: query).map{ $0.first }
    }
    
    public func requestLoadHoorayDetail(_ id: String) -> Maybe<HoorayDetail> {
        
        typealias Key = HoorayMappingKey
        
        let loadHooray = self.requestLoadHooray(id)
        
        let thenAppendAcks: (Hooray?) -> Maybe<HoorayDetail> = { [weak self] hooray in
            guard let self = self else { return .empty() }
            guard let hooray = hooray else {
                return .error(RemoteErrors.notFound("Hooray", reason: nil))
            }
            let acksCollectionRef = self.fireStoreDB.collection(.hoorayAcks)
            let acksQuery = acksCollectionRef.whereField(Key.uid.rawValue, isEqualTo: id)
            let acks: Maybe<[HoorayAckInfo]> = self.load(query: acksQuery).catchAndReturn([])
            return acks.map{ HoorayDetail(info: hooray, acks: $0, reactions: []) }
        }
        
        let thenAppendReactions: (HoorayDetail) -> Maybe<HoorayDetail> = { [weak self] detail in
            guard let self = self else { return .empty() }
            let reactionCollectionRef = self.fireStoreDB.collection(.hoorayReactions)
            let reactionQuery = reactionCollectionRef.whereField(Key.uid.rawValue, isEqualTo: id)
            let reactions: Maybe<[HoorayReaction]> = self.load(query: reactionQuery).catchAndReturn([])
            return reactions.map{ HoorayDetail(info: detail.hoorayInfo, acks: detail.acks, reactions: $0) }
        }
        
        return loadHooray
            .flatMap(thenAppendAcks)
            .flatMap(thenAppendReactions)
    }
}


// MARK: - publish new hooray

extension FirebaseServiceImple {
    
    private func appendPlaceIDWithSaveIfNeed(_ hoorayForm: NewHoorayForm,
                                             placeForm: NewPlaceForm?) -> Maybe<NewHoorayForm> {
        switch placeForm {
        case let .some(form):
            return self.requestRegister(new: form).map{ hoorayForm.append($0.uid) }

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
        
        let thenSendMessages: ([String]) -> Void = { [weak self] userIDs in
            let message = NewHoorayMessage(new: newHooray)
            self?.batchSendForgroundMessages(message, toUsers: userIDs)
        }
        self.loadNearbyUserIDs(center: newHooray.location, radius: newHooray.spreadDistance)
            .subscribe(onSuccess: thenSendMessages)
            .disposed(by: self.disposeBag)
    }
    
    private func loadNearbyUserIDs(center: Coordinate, radius: Double) -> Maybe<[String]> {
        
        let collectionRef = self.fireStoreDB.collection(.userLocation)
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
