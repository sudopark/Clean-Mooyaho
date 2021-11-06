//
//  BatchUpload+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/11/06.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestBatchUpload<T>(_ type: T.Type, data: [T]) -> Maybe<Void> {
        
        let typeName = String(describing: type.self)
        switch typeName {
        case String(describing: ItemCategory.self):
            return self.batchUpload(categories: data as? [ItemCategory])
            
        case String(describing: ReadItem.self):
            return self.batchUpload(items: data as? [ReadItem])
            
        case String(describing: ReadLinkMemo.self):
            return self.batchUpload(memos: data as? [ReadLinkMemo])
            
        default: return .empty()
        }
    }
    
    private func batchUpload(categories: [ItemCategory]?) -> Maybe<Void> {
        guard let categories = categories, categories.isNotEmpty else {
            return .just()
        }
        return self.requestUpdateCategories(categories)
    }
    
    private func batchUpload(items: [ReadItem]?) -> Maybe<Void> {
        
        guard let items = items, items.isNotEmpty else {
            return .just()
        }
        
        let collections = items.compactMap { $0 as? ReadCollection }
        let links = items.compactMap { $0 as? ReadLink }
        let uploadCollections = collections.isNotEmpty
            ? self.batch(.readCollection, write: self.uploadingAction(collections))
            : .just()
        
        let thenUploadLinks: () -> Maybe<Void> = { [weak self] in
            guard let self = self else { return .empty() }
            guard links.isNotEmpty else { return .just() }
            return self.batch(.readLinks, write: self.uploadingAction(links))
        }
        return uploadCollections
            .flatMap(thenUploadLinks)
    }
    
    private func batchUpload(memos: [ReadLinkMemo]?) -> Maybe<Void> {
        guard let memos = memos, memos.isNotEmpty else {
            return .just()
        }
        return self.batch(.linkMemo, write: self.uploadingAction(memos))
    }
    
    private func uploadingAction<D: DocumentMappable>(_ documents: [D]) -> (CollectionReference) -> Void {
        return { collectionRef in
            documents.forEach { document in
                let (docuID, json) = document.asDocument()
                let docRef = collectionRef.document(docuID)
                docRef.setData(json, merge: true)
            }
        }
    }
}
