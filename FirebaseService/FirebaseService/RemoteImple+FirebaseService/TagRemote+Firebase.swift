//
//  TagRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/10.
//

import Foundation

import RxSwift

import Domain
import DataStore



extension FirebaseServiceImple {
    
    public func requestRegisterTag(_ tag: Tag) -> Maybe<Void> {
        switch tag.tagType {
        case .userComments:
            return self.save(tag, at: .commentTag, merging: true)
            
        case .userFeeling:
            return self.save(tag, at: .feelingTag, merging: true)
            
        default:
            return .error(RemoteErrors.invalidRequest("unsupport tag type"))
        }
    }
    
    public func requestLoadPlaceCommnetTags(_ keyword: String,
                                            cursor: String?) -> Maybe<SuggestTagResultCollection> {
        var query = self.fireStoreDB.collection(.commentTag)
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: keyword)
            .order(by: FieldPath.documentID())
        if let cursor = cursor {
            query = query.start(after: [cursor])
        }
        query = query.limit(to: 30)
        
        let tags: Maybe<[Tag]> = self.load(query: query)
        return tags.map{ .init(query: keyword, tags: $0, cursor: $0.last?.keyword) }
    }
    
    public func requestLoadUserFeelingTags(_ keyword: String,
                                           cursor: String?) -> Maybe<SuggestTagResultCollection> {
        var query = self.fireStoreDB.collection(.feelingTag)
            .whereField(FieldPath.documentID(), isGreaterThanOrEqualTo: keyword)
            .order(by: FieldPath.documentID())
        if let cursor = cursor {
            query = query.start(after: [cursor])
        }
        query = query.limit(to: 30)
        
        let tags: Maybe<[Tag]> = self.load(query: query)
        return tags.map{ .init(query: keyword, tags: $0, cursor: $0.last?.keyword) }
    }
}
