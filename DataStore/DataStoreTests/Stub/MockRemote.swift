//
//  StubRemote.swift
//  DataStoreTests
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit
import Extensions

@testable import DataStore


class MockRemote: Remote, LinkPreviewRemote, Mocking {
    
    var signInMemberID: String?
    
    // auth
    func requestSignInAnonymously() -> Maybe<Auth> {
        self.verify(key: "requestSignInAnonymously")
        return self.resolve(key: "requestSignInAnonymously") ?? .empty()
    }
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult> {
        return self.resolve(key: "requestSignIn:withEmail") ?? .empty()
    }
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult> {
        return self.resolve(key: "requestSignIn:credential") ?? .empty()
    }
    
    func requestSignout() -> Maybe<Void> {
        return self.resolve(key: "requestSignout") ?? .empty()
    }
    
    func requestWithdrawal() -> Maybe<Void> {
        return self.resolve(key: "requestWithdrawal") ?? .empty()
    }
    
    func requestRecoverAccount() -> Maybe<Member> {
        return self.resolve(key: "requestRecoverAccount") ?? .empty()
    }
    
    // member
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateUserPresence") ?? .empty()
    }
    
    let uploadMemberProfileImageStatus = PublishSubject<MemberProfileUploadStatus>()
    func requestUploadMemberProfileImage(_ memberID: String,
                                         data: Data, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return self.uploadMemberProfileImageStatus.asObservable()
    }
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         filePath: String, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return self.uploadMemberProfileImageStatus.asObservable()
    }
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member> {
        return self.resolve(key: "requestUpdateMemberProfileFields") ?? .empty()
    }
    
    func requestLoadMember(_ ids: [String]) -> Maybe<[Member]> {
        return self.resolve(key: "requestLoadMember") ?? .empty()
    }
    
    // messaging
    func requestSendForground(message: Message, to userID: String) -> Maybe<Void> {
        return self.resolve(key: "requestSendForground") ?? .empty()
    }
    
    // read item
    func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> {
        return self.resolve(key: "requestLoadMyItems") ?? .empty()
    }
    
    func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        return self.resolve(key: "requestLoadCollectionItems") ?? .empty()
    }
    
    func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateReadCollection") ?? .empty()
    }
    
    func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateReadLink") ?? .empty()
    }
    
    func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection> {
        return self.resolve(key: "requestLoadCollection") ?? .empty()
    }
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateItem") ?? .empty()
    }
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        return self.resolve(key: "requestFindLinkItem") ?? .empty()
    }
    
    func requestRemoveItem(_ item: ReadItem) -> Maybe<Void> {
        return self.resolve(key: "requestRemoveItem") ?? .empty()
    }
    
    func requestSearchItem(_ name: String) -> Maybe<[SearchReadItemIndex]> {
        return self.resolve(key: "requestSuggestItem") ?? .empty()
    }
    
    func requestLoadAllSearchableReadItemTexts(memberID: String) -> Maybe<[String]> {
        return self.resolve(key: "requestLoadAllSearchableReadItemTexts") ?? .empty()
    }
    
    func requestLoadReadLink(linkID: String) -> Maybe<ReadLink> {
        return self.resolve(key: "requestLoadReadLink") ?? .empty()
    }
    
    func requestSuggestNextReadItems(for memberID: String, size: Int) -> Maybe<[ReadItem]> {
        return self.resolve(key: "requestSuggestNextReadItems") ?? .empty()
    }
    
    func requestLoadItems(ids: [String]) -> Maybe<[ReadItem]> {
        return self.resolve(key: "requestLoadItems") ?? .empty()
    }
    
    func requestLoadFavoriteItemIDs() -> Maybe<[String]> {
        return self.resolve(key: "requestLoadFavoriteItemIDs") ?? .empty()
    }
    
    func requestToggleFavoriteItemID(_ id: String, isOn: Bool) -> Maybe<Void> {
        return self.resolve(key: "requestToggleFavoriteItemID") ?? .empty()
    }
    
    // options
    func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        return self.resolve(key: "requestLoadReadItemCustomOrder") ?? .empty()
    }
    
    func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateReadItemCustomOrder") ?? .empty()
    }
    
    // preview
    func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> {
        return self.resolve(key: "requestLoadPreview") ?? .empty()
    }
    
    // category
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return self.resolve(key: "requestLoadCategories") ?? .empty()
    }
    
    func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateCategories") ?? .empty()
    }
    
    func requestUpdateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateCategory") ?? .empty()
    }
    
    func requestSuggestCategories(_ name: String, cursor: String?) -> Maybe<SuggestCategoryCollection> {
        return self.resolve(key: "requestSuggestCategories") ?? .empty()
    }
    
    func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        return self.resolve(key: "requestLoadLastestCategories") ?? .empty()
    }
    
    func requestLoadCategories(earilerThan creatTime: TimeStamp, pageSize: Int) -> Maybe<[ItemCategory]> {
        return self.resolve(key: "requestLoadCategories:earilerThan") ?? .empty()
    }
    
    func requestDeleteCategory(_ itemID: String) -> Maybe<Void> {
        return self.resolve(key: "requestDeleteCategory") ?? .empty()
    }
    
    func requestFindCategory(by name: String) -> Maybe<ItemCategory?> {
        return self.resolve(key: "requestFindCategory") ?? .empty()
    }
    
    // memo
    func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        return self.resolve(key: "requestLoadMemo") ?? .empty()
    }
    
    func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateMemo") ?? .empty()
    }
    
    func requestDeleteMemo(for linkItemID: String) -> Maybe<Void> {
        return self.resolve(key: "requestDeleteMemo") ?? .empty()
    }
    
    // batch
    var batchUploadMocking: ((Error?) -> Void)?
    var didUploaded: [Any]?
    func requestBatchUpload<T>(_ type: T.Type, data: [T]) -> Maybe<Void> {
        return Maybe.create { callback in
            
            self.batchUploadMocking = { error in
                if let error = error {
                    callback(.error(error))
                } else {
                    self.didUploaded = data
                    callback(.success(()))
                }
            }
            
            return Disposables.create { }
        }
    }
    
    // share item
    func requestShare(collectionID: String) -> Maybe<SharedReadCollection> {
        return self.resolve(key: "requestShare") ?? .empty()
    }
    
    func requestStopShare(collectionID: String) -> Maybe<Void> {
        return self.resolve(key: "requestStopShare") ?? .empty()
    }
    
    func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        return self.resolve(key: "requestLoadLatestSharedCollections") ?? .empty()
    }
    
    func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection> {
        return self.resolve(key: "requestLoadSharedCollection") ?? .empty()
    }
    
    func requestLoadMySharingCollectionIDs() -> Maybe<[String]> {
        return self.resolve(key: "requestLoadMySharingCollectionIDs") ?? .empty()
    }
    
    func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return self.resolve(key: "requestLoadMySharingCollection") ?? .empty()
    }
    
    func requestLoadSharedCollectionSubItems(for collectionID: String) -> Maybe<[SharedReadItem]> {
        return self.resolve(key: "requestLoadSharedCollectionSubItems") ?? .empty()
    }
    
    func requestRemoveSharedCollection(shareID: String) -> Maybe<Void> {
        return self.resolve(key: "requestRemoveSharedCollection") ?? .empty()
    }
    
    func requestLoadAllSharedCollectionIDs() -> Maybe<[String]> {
        return self.resolve(key: "requestLoadAllSharedCollectionIDs") ?? .empty()
    }
    
    func requestLoadSharedCollections(by shareIDs: [String]) -> Maybe<[SharedReadCollection]> {
        return self.resolve(key: "requestLoadSharedCollections") ?? .empty()
    }
    
    func requestLoadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        return self.resolve(key: "requestLoadSharedMemberIDs") ?? .empty()
    }
    
    func requestExcludeCollectionSharing(_ shareID: String, for memberID: String) -> Maybe<Void> {
        return self.resolve(key: "requestExcludeCollectionSharing") ?? .empty()
    }
    
    // help
    func requestLeaveFeedback(_ feedback: Feedback) -> Maybe<Void> {
        return self.resolve(key: "requestLeaveFeedback") ?? .empty()
    }
}
