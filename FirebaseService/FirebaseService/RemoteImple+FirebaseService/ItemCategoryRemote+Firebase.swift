//
//  ItemCategoryRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/10/10.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    private typealias Key = CategoryMappingKey
    
    public func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        
        let updateIndexes: () -> Void = { [weak self] in
            self?.updateIndexes(for: memberID, categories: categories)
        }
        
        let updateCategories: (CollectionReference) -> Void = { collectionRef in
            categories.forEach { cate in
                let (docuID, json) = cate.asDocument()
                let docuRef = collectionRef.document(docuID)
                docuRef.setData(json, merge: true)
            }
        }
        return self.batch(.itemCategory, write: updateCategories)
            .do(onNext: updateIndexes)
    }
    
    private func updateIndexes(for memberID: String, categories: [ItemCategory]) {
        
        let indexes = categories.map { $0.asIndexes(memberID) }
        let updating: (CollectionReference) -> Void = { collectionRef in
            indexes.forEach { index in
                let (docuID, json) = index.asDocument()
                let docuRef = collectionRef.document(docuID)
                docuRef.setData(json, merge: true)
            }
        }
        self.batch(.suggestCategoryIndexes, write: updating)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        guard let _ = self.signInMemberID else {
            return .empty()
        }
        let collectionRef = self.fireStoreDB.collection(.itemCategory)
        let query = collectionRef.whereField(FieldPath.documentID(), in: ids)
        return self.load(query: query)
    }
    
    private typealias SuggestKey = SuggestIndexKeys
    
    public func requestSuggestCategories(_ name: String,
                                         cursor: String?) -> Maybe<SuggestCategoryCollection> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        let collectionRef = self.fireStoreDB.collection(.suggestCategoryIndexes)
        let endText = "\(name)\u{F8FF}"
        let query = collectionRef
            .whereField(SuggestKey.ownerID.rawValue, isEqualTo: memberID)
            .order(by: SuggestKey.keyword.rawValue)
            .whereField(SuggestKey.keyword.rawValue, isGreaterThanOrEqualTo: name)
            .whereField(SuggestKey.keyword.rawValue, isLessThanOrEqualTo: endText)
            .limit(to: 50)
        let indexes: Maybe<[SuggestIndex]> = self.load(query: query)
        let suggestCategories = indexes.map { $0.compactMap { $0.asSuggestCategory() } }
        return suggestCategories.map {
            SuggestCategoryCollection(query: name, categories: $0, cursor: nil)
        }
    }
    
    public func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        guard let memberID = self.signInMemberID else {
            return .empty()
        }
        let collectionRef = self.fireStoreDB.collection(.suggestCategoryIndexes)
        let query = collectionRef
            .whereField(SuggestKey.ownerID.rawValue, isEqualTo: memberID)
            .order(by: SuggestKey.lastUpdated.rawValue, descending: true)
            .limit(to: 100)
        let indexes: Maybe<[SuggestIndex]> = self.load(query: query)
        return indexes.map { $0.compactMap { $0.asSuggestCategory() } }
    }
}
