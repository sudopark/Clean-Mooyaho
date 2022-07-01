//
//  RemoteImple.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/09/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import Extensions
import DataStore
import FirebaseService
 

final class RemoteImple: Remote {
    
    private let firebaseRemote: FirebaseRemote
    private let linkPreviewRemote: LinkPreviewRemote
    
    var signInMemberID: String? {
        get {
            return self.firebaseRemote.signInMemberID
        } set {
            self.firebaseRemote.signInMemberID = newValue
        }
    }
    
    init(firebaseRemote: FirebaseRemote, linkPreviewRemote: LinkPreviewRemote) {
        self.firebaseRemote = firebaseRemote
        self.linkPreviewRemote = linkPreviewRemote
    }
}

extension RemoteImple {
    
    // auth
    func requestSignInAnonymously() -> Maybe<Domain.Auth> {
        return self.firebaseRemote.requestSignInAnonymously()
    }
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult> {
        return self.firebaseRemote.requestSignIn(withEmail: email, password: password)
    }
    
    func requestSignIn(using credential: Domain.OAuthCredential) -> Maybe<SigninResult> {
        return self.firebaseRemote.requestSignIn(using: credential)
    }
    
    func requestWithdrawal() -> Maybe<Void> {
        return self.firebaseRemote.requestWithdrawal()
    }
    
    func requestSignout() -> Maybe<Void> {
        return self.firebaseRemote.requestSignout()
    }
    
    func requestRecoverAccount() -> Maybe<Member> {
        return self.firebaseRemote.requestRecoverAccount()
    }
    
    // member
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdatePushToken(userID, deviceID: deviceID, newToken: newToken)
    }
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         data: Data, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return self.firebaseRemote
            .requestUploadMemberProfileImage(memberID, data: data, ext: ext, size: size)
    }
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         filePath: String, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return self.firebaseRemote
            .requestUploadMemberProfileImage(memberID, filePath: filePath, ext: ext, size: size)
    }
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member> {
        return self.firebaseRemote.requestUpdateMemberProfileFields(memberID, fields: fields, thumbnail: thumbnail)
    }
    
    func requestLoadMember(_ ids: [String]) -> Maybe<[Member]> {
        return self.firebaseRemote.requestLoadMember(ids)
    }
    
    // messaging
    func requestSendForground(message: Message, to userID: String) -> Maybe<Void> {
        return self.firebaseRemote.requestSendForground(message: message, to: userID)
    }
    
    
    // read item
    func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]> {
        return self.firebaseRemote.requestLoadMyItems(for: memberID)
    }
    
    func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]> {
        return self.firebaseRemote.requestLoadCollectionItems(collectionID: collectionID)
    }
    
    func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateReadCollection(collection)
    }
    
    func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateReadLink(link)
    }
    
    func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection> {
        return self.firebaseRemote.requestLoadCollection(collectionID: collectionID)
    }
    
    func requestLoadReadLink(linkID: String) -> Maybe<ReadLink> {
        return self.firebaseRemote.requestLoadReadLink(linkID: linkID)
    }
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateItem(params)
    }
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?> {
        return self.firebaseRemote.requestFindLinkItem(using: url)
    }
    
    func requestRemoveItem(_ item: ReadItem) -> Maybe<Void> {
        return self.firebaseRemote.requestRemoveItem(item)
    }
    
    func requestSearchItem(_ name: String) -> Maybe<[SearchReadItemIndex]> {
        return self.firebaseRemote.requestSearchItem(name)
    }
    
    func requestSuggestNextReadItems(for memberID: String, size: Int) -> Maybe<[ReadItem]> {
        return self.firebaseRemote.requestSuggestNextReadItems(for: memberID, size: size)
    }
    
    func requestLoadItems(ids: [String]) -> Maybe<[ReadItem]> {
        return self.firebaseRemote.requestLoadItems(ids: ids)
    }
    
    func requestLoadFavoriteItemIDs() -> Maybe<[String]> {
        return self.firebaseRemote.requestLoadFavoriteItemIDs()
    }
    
    func requestToggleFavoriteItemID(_ id: String, isOn: Bool) -> Maybe<Void> {
        return self.firebaseRemote.requestToggleFavoriteItemID(id, isOn: isOn)
    }
    
    // read item option
    func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?> {
        return self.firebaseRemote.requestLoadReadItemCustomOrder(for: collectionID)
    }
    
    func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateReadItemCustomOrder(for: collection, itemIDs: itemIDs)
    }
    
    
    // link preview
    func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> {
        return self.linkPreviewRemote.requestLoadPreview(url)
    }
    
    
    // itemCategory
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]> {
        return self.firebaseRemote.requestLoadCategories(ids)
    }
    
    func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateCategories(categories)
    }
    
    func requestUpdateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateCategory(by: params)
    }
    
    func requestSuggestCategories(_ name: String, cursor: String?) -> Maybe<SuggestCategoryCollection> {
        return self.firebaseRemote.requestSuggestCategories(name, cursor: cursor)
    }
    
    func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        return self.firebaseRemote.requestLoadLastestCategories()
    }
    
    func requestLoadCategories(earilerThan creatTime: TimeStamp, pageSize: Int) -> Maybe<[ItemCategory]> {
        return self.firebaseRemote.requestLoadCategories(earilerThan: creatTime, pageSize: pageSize)
    }
    
    func requestDeleteCategory(_ itemID: String) -> Maybe<Void> {
        return self.firebaseRemote.requestDeleteCategory(itemID)
    }
    
    func requestFindCategory(by name: String) -> Maybe<ItemCategory?> {
        return self.firebaseRemote.requestFindCategory(by: name)
    }
    
    // memo
    func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?> {
        return self.firebaseRemote.requestLoadMemo(for: linkItemID)
    }
    
    func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateMemo(newValue)
    }
    
    func requestDeleteMemo(for linkItemID: String) -> Maybe<Void> {
        return self.firebaseRemote.requestDeleteMemo(for: linkItemID)
    }
    
    // batch
    func requestBatchUpload<T>(_ type: T.Type, data: [T]) -> Maybe<Void> {
        return self.firebaseRemote.requestBatchUpload(type, data: data)
    }
    
    // share item
    func requestShare(collectionID: String) -> Maybe<SharedReadCollection> {
        return self.firebaseRemote.requestShare(collectionID: collectionID)
    }
    
    func requestStopShare(collectionID: String) -> Maybe<Void> {
        return self.firebaseRemote.requestStopShare(collectionID: collectionID)
    }
    
    func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        return self.firebaseRemote.requestLoadLatestSharedCollections()
    }
    
    func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection> {
        return self.firebaseRemote.requestLoadSharedCollection(by: shareID)
    }
    
    func requestLoadMySharingCollectionIDs() -> Maybe<[String]> {
        return self.firebaseRemote.requestLoadMySharingCollectionIDs()
    }
    
    func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return self.firebaseRemote.requestLoadMySharingCollection(collectionID)
    }
    
    func requestLoadSharedCollectionSubItems(for collectionID: String) -> Maybe<[SharedReadItem]> {
        return self.firebaseRemote.requestLoadSharedCollectionSubItems(for: collectionID)
    }
    
    func requestRemoveSharedCollection(shareID: String) -> Maybe<Void> {
        return self.firebaseRemote.requestRemoveSharedCollection(shareID: shareID)
    }
    
    func requestLoadAllSearchableReadItemTexts(memberID: String) -> Maybe<[String]> {
        return self.firebaseRemote.requestLoadAllSearchableReadItemTexts(memberID: memberID)
    }
    
    func requestLoadAllSharedCollectionIDs() -> Maybe<[String]> {
        return self.firebaseRemote.requestLoadAllSharedCollectionIDs()
    }
    
    func requestLoadSharedCollections(by shareIDs: [String]) -> Maybe<[SharedReadCollection]> {
        return self.firebaseRemote.requestLoadSharedCollections(by: shareIDs)
    }
    
    func requestLoadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]> {
        return self.firebaseRemote.requestLoadSharedMemberIDs(of: collectionShareID)
    }
    
    func requestExcludeCollectionSharing(_ shareID: String, for memberID: String) -> Maybe<Void> {
        return self.firebaseRemote.requestExcludeCollectionSharing(shareID, for: memberID)
    }
    
    // help
    func requestLeaveFeedback(_ feedback: Feedback) -> Maybe<Void> {
        return self.firebaseRemote.requestLeaveFeedback(feedback)
    }
}
