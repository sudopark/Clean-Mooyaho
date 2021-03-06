//
//  EmptyRemote.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/29.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import Extensions
import DataStore


final class EmptyRemote: Remote {
    
    func requestRecoverAccount() -> Maybe<Member> {
        return .empty()
    }
    
    func requestExcludeCollectionSharing(_ shareID: String, for memberID: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        return .empty()
    }
    
    func requestLeaveFeedback(_ feedback: Feedback) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadAllSharedCollectionIDs() -> Maybe<[String]> {
        return .empty()
    }
    
    func requestLoadSharedCollections(by shareIDs: [String]) -> Maybe<[SharedReadCollection]> {
        return .empty()
    }
    
    func requestWithdrawal() -> Maybe<Void> {
        return .empty()
    }
    
    func requestSignout() -> Maybe<Void> {
        return .empty()
    }
    
    func requestUpdateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void> {
        return .empty()
    }
    
    func requestFindCategory(by name: String) -> Maybe<ItemCategory?> {
        return .empty()
    }
    
    func requestLoadCategories(earilerThan creatTime: TimeStamp, pageSize: Int) -> Maybe<[ItemCategory]> {
        return .empty()
    }
    
    func requestDeleteCategory(_ itemID: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestSuggestNextReadItems(for memberID: String, size: Int) -> Maybe<[ReadItem]> {
        return .empty()
    }
    
    func requestLoadItems(ids: [String]) -> Maybe<[ReadItem]> {
        return .empty()
    }
    
    func requestLoadFavoriteItemIDs() -> Maybe<[String]> {
        return .empty()
    }
    
    func requestToggleFavoriteItemID(_ id: String, isOn: Bool) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadReadLink(linkID: String) -> Maybe<ReadLink> {
        return .empty()
    }
    
    func requestLoadAllSearchableReadItemTexts(memberID: String) -> Maybe<[String]> {
        return .empty()
    }
    
    func requestSearchItem(_ name: String) -> Maybe<[SearchReadItemIndex]> {
        return .empty()
    }
    
    func requestRemoveItem(_ item: ReadItem) -> Maybe<Void> {
        return .empty()
    }
    
    func requestRemoveSharedCollection(shareID: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadSharedCollectionSubItems(for collectionID: String) -> Maybe<[SharedReadItem]> {
        return .empty()
    }
    
    func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return .empty()
    }
    
    func requestLoadMySharingCollectionIDs() -> Maybe<[String]> {
        return .empty()
    }
    
    func requestShare(collectionID: String) -> Maybe<SharedReadCollection> {
        return .empty()
    }
    
    func requestStopShare(collectionID: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        return .empty()
    }
    
    func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection> {
        return .empty()
    }
    
    func requestUploadMemberProfileImage(_ memberID: String, filePath: String, ext: String, size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return .empty()
    }
    
    func requestBatchUpload<T>(_ type: T.Type, data: [T]) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return .empty()
    }
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        return .empty()
    }
    
    func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        return .empty()
    }
    
    func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        return .empty()
    }
    
    func requestDeleteMemo(for linkItemID: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        return .empty()
    }
    
    func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void> {
        return .empty()
    }
    
    func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return .empty()
    }
    
    func requestSuggestCategories(_ name: String,
                                  cursor: String?) -> Maybe<SuggestCategoryCollection> {
        .empty()
    }
    
    func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        .empty()
    }
    
    var signInMemberID: String?
    
    func requestUploadMemberProfileImage(_ memberID: String, data: Data, ext: String, size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return .empty()
    }
    
    func requestUpdateMemberProfileFields(_ memberID: String, fields: [MemberUpdateField], thumbnail: MemberThumbnail?) -> Maybe<Member> {
        return .empty()
    }
    
    
    func requestSignInAnonymously() -> Maybe<Auth> {
        return .empty()
    }
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult> {
        return .empty()
    }
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult> {
        return .empty()
    }
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestSendForground(message: Message, to userID: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadMember(_ ids: [String]) -> Maybe<[Member]> {
        return .empty()
    }
    
    func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> { .empty() }
    
    func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> { .empty() }
    
    func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void>  { .empty() }
    
    func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void>  { .empty() }
    
    func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> { .empty() }
    
    func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection> { .empty() }
}
