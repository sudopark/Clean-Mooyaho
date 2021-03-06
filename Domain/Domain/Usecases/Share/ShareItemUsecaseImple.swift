//
//  ShareItemUsecaseImple.swift
//  Domain
//
//  Created by sudo.park on 2021/11/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


public final class ShareItemUsecaseImple: ShareReadCollectionUsecase, SharedReadCollectionLoadUsecase, SharedReadCollectionUpdateUsecase, SharedReadCollectionHandleUsecase {
    
    private let shareURLScheme: String
    private let shareRepository: ShareItemRepository
    private let authInfoProvider: AuthInfoProvider
    private let sharedDataService: SharedDataStoreService
    
    public init(shareURLScheme: String,
                shareRepository: ShareItemRepository,
                authInfoProvider: AuthInfoProvider,
                sharedDataService: SharedDataStoreService) {
        
        self.shareURLScheme = shareURLScheme
        self.shareRepository = shareRepository
        self.authInfoProvider = authInfoProvider
        self.sharedDataService = sharedDataService
    }
    
    private let disposeBag = DisposeBag()
}


// MARK: - share

extension ShareItemUsecaseImple {
    
    public func shareCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        
        guard self.authInfoProvider.isSignedIn() else {
            return .error(ApplicationErrors.sigInNeed)
        }
     
        let updateSharingID: (SharedReadCollection) -> Void = { [weak self] _ in
            let datKey = SharedDataKeys.mySharingCollectionIDs.rawValue
            self?.sharedDataService.update([String].self, key: datKey) {
                return ($0 ?? []).filter { $0 != collectionID } + [collectionID]
            }
        }
        return self.shareRepository.requestShareCollection(collectionID)
            .do(onNext: updateSharingID)
    }
    
    public func stopShare(collection collectionID: String) -> Maybe<Void> {
        
        let updateSharingID: () -> Void = { [weak self] in
            let datKey = SharedDataKeys.mySharingCollectionIDs.rawValue
            self?.sharedDataService.update([String].self, key: datKey) {
                return ($0 ?? []).filter { $0 != collectionID }
            }
        }
        return self.shareRepository.requestStopShare(readCollection: collectionID)
            .do(onNext: updateSharingID)
    }
    
    public func refreshMySharingColletionIDs() {
        
        guard self.authInfoProvider.isSignedIn() else {
            return
        }
        
        let updateStore: ([String]) -> Void = { [weak self] ids in
            self?.sharedDataService.save([String].self, key: .mySharingCollectionIDs, ids)
        }
        self.shareRepository.requestLoadMySharingCollectionIDs()
            .subscribe(onNext: updateStore)
            .disposed(by: self.disposeBag)
    }
    
    public var mySharingCollectionIDs: Observable<[String]> {
        return self.sharedDataService
            .observeWithCache([String].self, key: SharedDataKeys.mySharingCollectionIDs.rawValue)
            .compactMap { $0 }
    }
    
    public func excludeCollectionSharing(_ shareID: String, for memberID: String) -> Maybe<Void> {
        return self.shareRepository
            .requestExcludeCollectionSharing(shareID, for: memberID)
    }
}


// MARK: - load

extension ShareItemUsecaseImple {
    
    public func refreshLatestSharedReadCollection() {
        
        guard self.authInfoProvider.isSignedIn() == true else { return }
        
        let refreshStore: ([SharedReadCollection]) -> Void = { [weak self] collections in
            let datKey = SharedDataKeys.latestSharedCollections.rawValue
            self?.sharedDataService
                .update([SharedReadCollection].self, key: datKey) { _ in collections }
        }
        
        self.shareRepository.requestLoadLatestsSharedCollections()
            .subscribe(onNext: refreshStore)
            .disposed(by: self.disposeBag)
    }
    
    public var lastestSharedReadCollections: Observable<[SharedReadCollection]> {
        let datKey = SharedDataKeys.latestSharedCollections.rawValue
        return self.sharedDataService
            .observeWithCache([SharedReadCollection].self, key: datKey)
            .map { $0 ?? [] }
    }
    
    public func loadMyharingCollection(for collectionID: String) -> Observable<SharedReadCollection> {
        
        let datKey = SharedDataKeys.mySharingCollectionMap
        let prefetched = self.sharedDataService.fetch([String: SharedReadCollection].self, key: datKey)?[collectionID]
        
        let updateStore: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.sharedDataService.update([String: SharedReadCollection].self, key: datKey.rawValue) {
                ($0 ?? [:]) |> key(collectionID) .~ collection
            }
        }
        
        let refreshCollection = self.shareRepository.requestLoadMySharingCollection(collectionID)
            .do(onNext: updateStore)
            .mapAsOptional().asObservable()
        
        return refreshCollection
            .startWith(prefetched)
            .compactMap { $0 }
    }
    public func loadSharedCollectionSubItems(collectionID: String) -> Maybe<[SharedReadItem]> {
        return self.shareRepository.requestLoadSharedCollectionSubItems(collectionID: collectionID)
    }
    
    public func removeFromSharedList(shareID: String) -> Maybe<Void> {
        
        let removeFromSharedLatestsCollection: () -> Void = { [weak self] in
            let datKey = SharedDataKeys.latestSharedCollections.rawValue
            self?.sharedDataService.update([SharedReadCollection].self, key: datKey) {
                return ($0 ?? []).filter { $0.shareID != shareID }
            }
        }
        // remove
        return self.shareRepository.requestRemoveFromSharedList(shareID)
            .do(onNext: removeFromSharedLatestsCollection)
    }
    
    public func loadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        return self.shareRepository.requestLoadSharedMemberIDs(of: collectionShareID)
    }
}


// MARK: - handle

extension ShareItemUsecaseImple {
    
    public func canHandleURL(_ url: URL) -> Bool {
        guard self.parseSharedCollectionURL(url) != nil else { return false }
        return true
    }
    
    public func loadSharedCollection(by sharedURL: URL) -> Maybe<SharedReadCollection> {
        guard let shareID = self.parseSharedCollectionURL(sharedURL) else { return .empty() }
        
        let updateLatestSharedCollection: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.updateLatestSharedCollectionList(collection)
        }
                                          
        return self.shareRepository.requestLoadSharedCollection(by: shareID)
            .do(onNext: updateLatestSharedCollection)
    }
    
    private func parseSharedCollectionURL(_ url: URL) -> String? {
        guard let compomnents = URLComponents(url: url, resolvingAgainstBaseURL: true),
              compomnents.scheme == self.shareURLScheme,
              let host = compomnents.host, host == SharedReadCollection.shareHost,
              compomnents.path == "/\(SharedReadCollection.sharePath)",
              let queries = compomnents.queryItems?.asQueryDict()
        else {
            return nil
        }
        return queries["id"]
    }
    
    private func updateLatestSharedCollectionList(_ newCollection: SharedReadCollection) {
        let datKey = SharedDataKeys.latestSharedCollections.rawValue
        self.sharedDataService.update([SharedReadCollection].self, key: datKey) {
            return ($0 ?? [])
                |> { $0.removed(collectionID: newCollection.uid) }
                |> { [newCollection] + $0 }
        }
    }
}

private extension Array where Element == URLQueryItem {
    
    func asQueryDict() -> [String: String] {
        return self.reduce(into: [String: String]()) { acc, item in
            acc[item.name] = item.value
        }
    }
}

private extension Array where Element == SharedReadCollection {
    
    func removed(collectionID: String) -> Array {
        var sender = self
        sender.removeAll(where: { $0.uid == collectionID })
        return sender
    }
}

private extension Array where Element == String {
    func removed(collectionID: String) -> Array {
        var sender = self
        sender.removeAll(where: { $0 == collectionID })
        return sender
    }
}
