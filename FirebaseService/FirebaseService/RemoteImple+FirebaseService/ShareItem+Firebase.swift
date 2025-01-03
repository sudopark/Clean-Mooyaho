//
//  ShareItem+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/14.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain
import DataStore


private typealias Key = ShareItemMappingKey


// MARK: - share or stop

extension FirebaseServiceImple {
    
    public func requestShare(collectionID: String) -> Maybe<SharedReadCollection> {
        
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        
        let makeIndex = self.makeSharingIndex(collectionID, for: memberID)
        let thenLoadCollection: (SharingCollectionIndex) -> Maybe<SharedReadCollection>
        thenLoadCollection = { [weak self] index in
            guard let self = self else { return .empty() }
            return self.requestLoadCollection(collectionID: index.collectionID)
                .map { SharedReadCollection(shareID: index.shareID, collection: $0) }
        }
        let thenUpdateInbox: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.updateInbox(for: memberID) { $0.insertSharing(collection.uid) }
        }
        
        return makeIndex
            .flatMap(thenLoadCollection)
            .do(onNext: thenUpdateInbox)
    }
    
    private func makeSharingIndex(_ collectionID: String,
                                  for ownerID: String) -> Maybe<SharingCollectionIndex> {
        let jsonPayload = SharingCollectionIndex(shareID: "temp", ownerID: ownerID, collectionID: collectionID)
            .asDocument().1
        return self.saveNew(jsonPayload, at: .sharingCollectionIndex)
    }
    
    public func requestStopShare(collectionID: String) -> Maybe<Void> {
        
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        
        let collectionRef = self.fireStoreDB.collection(.sharingCollectionIndex)
        let query = collectionRef
            .whereField(Key.collectionID.rawValue, isEqualTo: collectionID)
            .whereField(Key.ownerID.rawValue, isEqualTo: memberID)
        let findIndex: Maybe<SharingCollectionIndex?> = self.load(query: query).map { $0.first }
        let thenRemoveOrNot: (SharingCollectionIndex?) -> Maybe<Void>
        thenRemoveOrNot = { [weak self] index in
            guard let shareID = index?.shareID else { return .just() }
            return self?.delete(shareID, at: .sharingCollectionIndex) ?? .empty()
        }
        let updateInbox: () -> Void = { [weak self] in
            self?.updateInbox(for: memberID) { $0.removedSharing(collectionID) }
        }
        return findIndex
            .flatMap(thenRemoveOrNot)
            .do(onNext: updateInbox)
    }
    
    public func requestExcludeCollectionSharing(_ shareID: String, for memberID: String) -> Maybe<Void> {
        
        return self.updateInboxAction(for: memberID) { inbox in
            return inbox
                |> \.sharedIDs %~ { $0.filter { $0 != shareID } }
        }
    }
}


// MARK: - load my sharing

extension FirebaseServiceImple {
    
    public func requestLoadMySharingCollectionIDs() -> Maybe<[String]> {
        
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        return self.loadMyInbox(for: memberID)
            .map { $0?.sharingCollectionIDs ?? [] }
    }
    
    // 내가 공유한 콜렉션 상세조회
    public func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        
        let collectionRef = self.fireStoreDB.collection(.sharingCollectionIndex)
        let query = collectionRef
            .whereField(Key.ownerID.rawValue, isEqualTo: memberID)
            .whereField(Key.collectionID.rawValue, isEqualTo: collectionID)
        let loadIndex: Maybe<[SharingCollectionIndex]> = self.load(query: query)
        
        let thenLoadCollection: (SharingCollectionIndex?) -> Maybe<SharedReadCollection> = { [weak self] index in
            guard let self = self else { return .empty() }
            guard let index = index else { return .error(ApplicationErrors.notFound) }
            return self.requestLoadCollection(collectionID: collectionID)
                .map { SharedReadCollection(shareID: index.shareID, collection: $0) }
        }
        
        return loadIndex
            .map { $0.first }
            .flatMap(thenLoadCollection)
    }
    
    public func requestLoadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        let collectionRef = self.fireStoreDB.collection(.sharedInbox)
        let query = collectionRef.whereField(Key.shared.rawValue, arrayContains: collectionShareID)
        let loadInboxes: Maybe<[SharedInbox]> = self.load(query: query)
        return loadInboxes.map { $0.map { $0.ownerID } }
    }
}


// MARK: - add shared or remove

extension FirebaseServiceImple {
    
    // 공유받은 콜렉션 조회 => 호출시 인박스에 추가됨
    public func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection> {
        
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        
        let emptyThenError: ([SharedReadCollection]) throws -> SharedReadCollection = {
            guard let first = $0.first else { throw ApplicationErrors.notFound }
            return first
        }
        
        let updateInbox: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.updateInbox(for: memberID) { $0.insertShared(collection.shareID) }
        }
        
        return self.requestLoadSharedCollections(by: [shareID])
            .map(emptyThenError)
            .do(onNext: updateInbox)
    }
    
    public func requestRemoveSharedCollection(shareID: String) -> Maybe<Void> {
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        return self.updateInboxAction(for: memberID) { $0.removedShared(shareID) }
    }
}


// MARK: - load shared collection

extension FirebaseServiceImple {
    
    // 내가 공유받은 최근 콜렉션 로드
    public func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        
        let loadSharedIDs = self.loadMyInbox(for: memberID).map { $0?.sharedIDs ?? [] }
            .map { Array($0.prefix(10)) }
        let thenLoadMatchingCollections: ([String]) -> Maybe<[SharedReadCollection]> = { [weak self] ids in
            return self?.requestLoadSharedCollections(by: ids) ?? .empty()
        }
        
        return loadSharedIDs
            .flatMap(thenLoadMatchingCollections)
    }
    
    public func requestLoadSharedCollectionSubItems(for collectionID: String) -> Maybe<[SharedReadItem]> {
        let loadItems: Maybe<[ReadItem]> = self.requestLoadCollectionItems(collectionID: collectionID)
        let asSharedItems: ([ReadItem]) -> [SharedReadItem] = { items in
            return items.compactMap { $0.asSharedSubItem() }
        }
        return loadItems
            .map(asSharedItems)
    }
    
    public func requestLoadAllSharedCollectionIDs() -> Maybe<[String]> {
        guard let memberID = self.signInMemberID else {
            return .error(ApplicationErrors.sigInNeed)
        }
        let loadMyInbox = self.loadMyInbox(for: memberID)
        return loadMyInbox
            .map { $0?.sharedIDs ?? [] }
    }
    
    public func requestLoadSharedCollections(by shareIDs: [String]) -> Maybe<[SharedReadCollection]> {
        guard shareIDs.isNotEmpty else { return .just([]) }
        let collectionRef = self.fireStoreDB.collection(.sharingCollectionIndex)
        let idChunks = shareIDs.slice(by: 10)
        let queries = idChunks.map { collectionRef.whereField(FieldPath.documentID(), in: $0) }
        let loadIndexes: Maybe<[SharingCollectionIndex]> = self.loadAll(queries: queries).asMaybe()
        
        let thenLoadCollections: ([SharingCollectionIndex]) -> Maybe<[SharedReadCollection]>
        thenLoadCollections = { [weak self] indexes in
            return self?.requestLoadSharedCollections(by: indexes) ?? .empty()
        }
        return loadIndexes
            .flatMap(thenLoadCollections)
    }
    
    private func requestLoadSharedCollections(by indexes: [SharingCollectionIndex]) -> Maybe<[SharedReadCollection]> {
        let colletionIDs = indexes.map { $0.collectionID }
        let collectionIDIndexMap = indexes.reduce(into: [String: SharingCollectionIndex]()) { $0[$1.collectionID] = $1 }
        
        guard colletionIDs.isNotEmpty else { return .just([]) }
        let collectionRef = self.fireStoreDB.collection(.readCollection)
        let idChunks = colletionIDs.slice(by: 10)
        let quries = idChunks.map { collectionRef.whereField(FieldPath.documentID(), in: $0) }
        let collections: Maybe<[ReadCollection]> = self.loadAll(queries: quries).asMaybe()
        return collections.map { $0.asSharedCollection(with: collectionIDIndexMap) }
    }
}


// MARK: - update inbox

private extension FirebaseServiceImple {

    private func updateInbox(for ownerID: String, _ mutating: @escaping (SharedInbox) -> SharedInbox) {
        
        self.updateInboxAction(for: ownerID, mutating)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func updateInboxAction(for ownerID: String,
                                   _ mutating: @escaping (SharedInbox) -> SharedInbox) -> Maybe<Void> {
        let loadOrMakeInbox = self.loadMyInbox(for: ownerID).map { $0 ?? SharedInbox(ownerID: ownerID) }
        let thenUpdateInbox: (SharedInbox) -> Maybe<Void> = { [weak self] inbox in
            guard let self = self else { return .empty() }
            let newInbox = mutating(inbox)
            return self.save(newInbox, at: .sharedInbox)
        }
        return loadOrMakeInbox
            .flatMap(thenUpdateInbox)
    }
    
    private func loadMyInbox(for ownerID: String) -> Maybe<SharedInbox?> {
        return self.load(docuID: ownerID, in: .sharedInbox)
    }
}

private extension Array where Element == ReadCollection {
    
    func asSharedCollection(with indexMap: [String: SharingCollectionIndex]) -> [SharedReadCollection] {
     
        let transform: (Element) -> SharedReadCollection? = { collection in
            guard let shareID = indexMap[collection.uid]?.shareID else { return nil }
            return .init(shareID: shareID, collection: collection)
        }
        return self.compactMap(transform)
    }
}

private extension ReadItem {
    
    func asSharedSubItem() -> SharedReadItem? {
        switch self {
        case let collection as ReadCollection:
            return SharedReadCollection(subCollection: collection)
            
        case let link as ReadLink:
            return SharedReadLink(link: link)
            
        default: return nil
        }
    }
}
