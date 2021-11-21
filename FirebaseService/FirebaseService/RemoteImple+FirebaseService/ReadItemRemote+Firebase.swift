//
//  ReadItemRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/09/18.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    private typealias Key = ReadItemMappingKey
    
    public func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        
        let collectionRef = self.fireStoreDB.collection(.readCollection)
        let collectionQuery = collectionRef
            .whereField(Key.ownerID.rawValue, isEqualTo: memberID)
            .whereField(Key.parentID.rawValue, isEqualTo: "root")
        
        let linkRef = self.fireStoreDB.collection(.readLinks)
        let linksQuery = linkRef
            .whereField(Key.ownerID.rawValue, isEqualTo: memberID)
            .whereField(Key.parentID.rawValue, isEqualTo: "root")
        
        return self.requestLoadMatchingItems(collectionQuery, linksQuery)
    }
    
    public func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        
        let collectionRef = self.fireStoreDB.collection(.readCollection)
        let collectionQuery = collectionRef
            .whereField(Key.parentID.rawValue, isEqualTo: collectionID)
        
        let linkRef = self.fireStoreDB.collection(.readLinks)
        let linksQuery = linkRef
            .whereField(Key.parentID.rawValue, isEqualTo: collectionID)
        
        
        return self.requestLoadMatchingItems(collectionQuery, linksQuery)
    }
    
    private func requestLoadMatchingItems(_ collectionQuery: Query,
                                          _ linksQuery: Query) -> Maybe<[ReadItem]> {
        let loadCollections: Maybe<[ReadCollection]> = self.load(query: collectionQuery).catchAndReturn([])
        let thenLoadLinks: ([ReadCollection]) -> Maybe<[ReadItem]> = { [weak self] collections in
            guard let self = self else { return .empty() }
            let links: Maybe<[ReadLink]> = self.load(query: linksQuery).catchAndReturn([])
            return links
                .map { collections + $0 }
        }

        return loadCollections.flatMap(thenLoadLinks)
    }
    
    public func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return self.save(collection, at: .readCollection, merging: true)
            .do(onNext: self.updateIndex(collection))
    }
    
    public func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        return self.save(link, at: .readLinks, merging: true)
            .do(onNext: self.updateIndex(link))
    }
    
    public func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let throwWhenNotExists: (ReadCollection?) throws -> ReadCollection
        throwWhenNotExists = { collection in
            guard let collection = collection else {
                throw RemoteErrors.notFound("ReadCollection", reason: nil)
            }
            return collection
        }
        return self.load(docuID: collectionID, in: .readCollection)
            .map(throwWhenNotExists)
    }
    
    public func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let newItem = params.applyChanges()
        switch newItem {
        case let collection as ReadCollection:
            return self.requestUpdateReadCollection(collection)
            
        case let link as ReadLink:
            return self.requestUpdateReadLink(link)
            
        default:
            return .error(RemoteErrors.invalidRequest("invalid read item type"))
        }
    }
    
    public func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        guard let _ = self.signInMemberID else {
            return .just(nil)
        }
        
        // TODO: error 떨구는지 nil로 나오는지 확인 필요
        let linkRef = self.fireStoreDB.collection(.readLinks)
        let query = linkRef.whereField(Key.link.rawValue, isEqualTo: url)
        return self.load(query: query).map { $0.first }
    }
    
    public func requestRemoveItem(_ item: ReadItem) -> Maybe<Void> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let collectionType: FireStoreCollectionType
        switch item {
        case is ReadCollection:
            collectionType = .readCollection
        case is ReadLink:
            collectionType = .readLinks
            
        default: return .error(RemoteErrors.invalidRequest("attempt to remove not a collection or link"))
        }
        
        return self.delete(item.uid, at: collectionType)
            .do(onNext: { [weak self] in
                self?.removeIndex(item)
            })
    }
    
    public func requestSearchItem(_ name: String) -> Maybe<[SearchReadItemIndex]> {
        typealias SuggestKey = SuggestIndexKeys
        guard let memberID = self.signInMemberID else { return .empty() }
        
        let collectionRef = self.fireStoreDB.collection(.suggestReadItemIndexes)
        let endText = "\(name)\u{F8FF}"
        let query = collectionRef
            .whereField(SuggestKey.ownerID.rawValue, isEqualTo: memberID)
            .order(by: SuggestKey.keyword.rawValue)
            .whereField(SuggestKey.keyword.rawValue, isGreaterThanOrEqualTo: name)
            .whereField(SuggestKey.keyword.rawValue, isLessThanOrEqualTo: endText)
        let indexes: Maybe<[SuggestIndex]> = self.load(query: query)
        return indexes.map {
            $0.compactMap { $0.asReadItemIndex() }
        }
    }
}


private extension FirebaseServiceImple {
    
    func updateIndex(_ item: ReadItem) -> () -> Void {
        return { [weak self] in

            switch item {
            case let collection as ReadCollection:
                self?.updateCollectionIndex(collection)
                
            case let link as ReadLink:
                self?.updateLinkIndex(link)
                
            default: return
            }
        }
    }
    
    private func updateCollectionIndex(_ collection: ReadCollection) {
        
        let index = collection.asIndex()
        self.save(index, at: .suggestReadItemIndexes)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func updateLinkIndex(_ link: ReadLink) {
    
        let prepareIndex = link.asIndexWithCustomTitle().map { .just($0) }
            ?? self.prepareIndexWithPreviewTitle(link)
        let thenUpdateIndex: (SuggestIndex) -> Maybe<Void> = { [weak self] index in
            return self?.save(index, at: .suggestReadItemIndexes) ?? .empty()
        }
        prepareIndex
            .flatMap(thenUpdateIndex)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func prepareIndexWithPreviewTitle(_ link: ReadLink) -> Maybe<SuggestIndex> {
        let indexWithpreview = self.linkPreviewRemote.requestLoadPreview(link.link)
            .timeout(.seconds(10), scheduler: MainScheduler.instance)
            .map { preview throws -> SuggestIndex in
                guard let title = preview.title else { throw RemoteErrors.notFound("preview", reason: nil) }
                return link.asIndex(with: title)
            }
        return indexWithpreview
    }
    
    func removeIndex(_ item: ReadItem) {
        
        self.delete(item.uid, at: .suggestReadItemIndexes)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
