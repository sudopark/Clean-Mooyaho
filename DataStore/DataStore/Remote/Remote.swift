//
//  Reomte.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import Extensions


// MARK: - Remote Error + Request Parameter Models

public enum RemoteErrors: Error {
    
    case operationFail(_ reason: Error?)
    case secretSignInFail(_ reason: Error?)
    case credentialSigninFail(_ reason: Error?)
    case deleteAccountFail(_ reason: Error?)
    case notSupportCredential(_ type: String)
    case loadFail(_ type: String, reason: Error?)
    case saveFail(_ type: String, reason: Error?)
    case updateFail(_ type: String, reason: Error?)
    case mappingFail(_ type: String)
    case invalidRequest(_ reason: String?)
    case notFound(_ type: String, reason: Error?)
    case fileUploadFail(_ reason: Error?)
}


public protocol AuthorizationNeed: AnyObject {
    
    var signInMemberID: String? { get set }
}


// MARK: - Remote Protocol

public protocol Remote: AuthRemote, MemberRemote, MessagingRemote,
                        ReadItemRemote, ReadItemOptionsRemote, LinkPreviewRemote, ItemCategoryRemote,
                        ReadLinkMemoRemote, BatchUploadRemote,
                        ShareItemRemote, HelpRemote { }

// MARK: - Auth remote

public protocol AuthRemote: Sendable {
    
    func requestSignInAnonymously() -> Maybe<Auth>
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult>
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult>
    
    func requestSignout() -> Maybe<Void>
    
    func requestWithdrawal() -> Maybe<Void>
    
    func requestRecoverAccount() -> Maybe<Member>
}

public protocol OAuthRemote: Sendable {
    
    func requestCustomToken(_ uniqID: String) -> Maybe<String>
}


// MARK: - Member remote

public protocol MemberRemote: Sendable {

    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void>
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         data: Data, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus>
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         filePath: String, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus>
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member>
    
    func requestLoadMember(_ ids: [String]) -> Maybe<[Member]>
}


// MARK: - Messaging

public protocol MessagingRemote: Sendable {
    
    func requestSendForground(message: Message, to userID: String) -> Maybe<Void>
}


// MARK: - ReadItem

public protocol ReadItemRemote: Sendable, AuthorizationNeed {
    
    func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]>
    
    func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]>
    
    func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void>
    
    func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void>
    
    func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection>
    
    func requestLoadReadLink(linkID: String) -> Maybe<ReadLink>
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?>
    
    func requestRemoveItem(_ item: ReadItem) -> Maybe<Void>
    
    func requestSearchItem(_ name: String) -> Maybe<[SearchReadItemIndex]>
    
    func requestLoadAllSearchableReadItemTexts(memberID: String) -> Maybe<[String]>
    
    func requestSuggestNextReadItems(for memberID: String, size: Int) -> Maybe<[ReadItem]>
    
    func requestLoadItems(ids: [String]) -> Maybe<[ReadItem]>
    
    func requestLoadFavoriteItemIDs() -> Maybe<[String]>
    
    func requestToggleFavoriteItemID(_ id: String, isOn: Bool) -> Maybe<Void>
}

public protocol ReadItemOptionsRemote: Sendable, AuthorizationNeed {
    
    func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?>
    
    func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void>
}

public protocol ReadLinkMemoRemote: AuthorizationNeed {
    
    func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?>
    
    func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void>
    
    func requestDeleteMemo(for linkItemID: String) -> Maybe<Void>
}

// MARK: - link preview

public protocol LinkPreviewRemote: Sendable {
    
    func requestLoadPreview(_ url: String) -> Maybe<LinkPreview>
}

// MARK: - item category

public protocol ItemCategoryRemote: Sendable, AuthorizationNeed {
    
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
    
    func requestUpdateCategory(by params: UpdateCategoryAttrParams) -> Maybe<Void>
 
    func requestSuggestCategories(_ name: String, cursor: String?) -> Maybe<SuggestCategoryCollection>
    
    func requestLoadLastestCategories() -> Maybe<[SuggestCategory]>
    
    func requestLoadCategories(earilerThan creatTime: TimeStamp, pageSize: Int) -> Maybe<[ItemCategory]>
    
    func requestDeleteCategory(_ itemID: String) -> Maybe<Void>
    
    func requestFindCategory(by name: String) -> Maybe<ItemCategory?>
}

// MARK: - BatchUploadRemote

public protocol BatchUploadRemote: Sendable {
    
    func requestBatchUpload<T>(_ type: T.Type, data: [T]) -> Maybe<Void>
}


// MARK: - Item share

public protocol ShareItemRemote: Sendable, AuthorizationNeed {
    
    func requestShare(collectionID: String) -> Maybe<SharedReadCollection>
    
    func requestStopShare(collectionID: String) -> Maybe<Void>
    
    func requestLoadMySharingCollectionIDs() -> Maybe<[String]>
    
    func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]>
    
    func requestLoadSharedCollection(by shareID: String) -> Maybe<SharedReadCollection>
    
    func requestLoadMySharingCollection(_ collectionID: String) -> Maybe<SharedReadCollection>
    
    func requestLoadSharedCollectionSubItems(for collectionID: String) -> Maybe<[SharedReadItem]>
    
    func requestRemoveSharedCollection(shareID: String) -> Maybe<Void>
    
    func requestLoadAllSharedCollectionIDs() -> Maybe<[String]>
    
    func requestLoadSharedCollections(by shareIDs: [String]) -> Maybe<[SharedReadCollection]>
    
    func requestLoadSharedMemberIDs(of collectionShareID: String) -> Maybe<[String]>
    
    func requestExcludeCollectionSharing(_ shareID: String, for memberID: String) -> Maybe<Void>
}


public protocol HelpRemote: Sendable {
    
    func requestLeaveFeedback(_ feedback: Feedback) -> Maybe<Void>
}
