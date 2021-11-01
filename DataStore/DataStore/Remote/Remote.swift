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

public protocol Remote: AuthRemote, MemberRemote,
                        PlaceRemote, TagRemote, HoorayRemote, MessagingRemote,
                        ReadItemRemote, ReadItemOptionsRemote, LinkPreviewRemote, ItemCategoryRemote,
                        ReadLinkMemoRemote { }

// MARK: - Auth remote

public protocol AuthRemote {
    
    func requestSignInAnonymously() -> Maybe<Auth>
    
    func requestSignIn(withEmail email: String, password: String) -> Maybe<SigninResult>
    
    func requestSignIn(using credential: OAuthCredential) -> Maybe<SigninResult>
}

public protocol OAuthRemote {
    
    func requestCustomToken(_ uniqID: String) -> Maybe<String>
}


// MARK: - Member remote

public protocol MemberRemote {
    
    func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void>
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void>
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip>
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         data: Data, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus>
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member>
    
    func requestLoadMember(_ ids: [String]) -> Maybe<[Member]>
}


// MARK: - place remote

public protocol PlaceRemote {
    
    func requesUpload(_ location: UserLocation) -> Maybe<Void>
    
    func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult>
    
    func requestSuggestPlace(_ query: String,
                             in location: UserLocation,
                             cursor: String?) -> Maybe<SuggestPlaceResult>
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection>
    
    func requestRegister(new place: NewPlaceForm) -> Maybe<Place>
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place>
}


// MARK: - Tag remote

public protocol TagRemote {
    
    func requestRegisterTag(_ tag: Tag) -> Maybe<Void>
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<SuggestTagResultCollection>
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<SuggestTagResultCollection>
}


// MARK: - Hooray

public protocol HoorayRemote {
    
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?>
    
    func requestPublishHooray(_ newForm: NewHoorayForm,
                              withNewPlace: NewPlaceForm?) -> Maybe<Hooray>
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]>
    
    func requestAckHooray(_ acks: [HoorayAckMessage])
    
    func requestLoadHooray(_ id: String) -> Maybe<Hooray?>
    
    func requestLoadHoorayDetail(_ id: String) -> Maybe<HoorayDetail>
}


// MARK: - Messaging

public protocol MessagingRemote {
    
    func requestSendForground(message: Message, to userID: String) -> Maybe<Void>
}


// MARK: - ReadItem

public protocol ReadItemRemote: AuthorizationNeed {
    
    func requestLoadMyItems(for memberID: String) -> Maybe<[ReadItem]>
    
    func requestLoadCollectionItems(collectionID: String) -> Maybe<[ReadItem]>
    
    func requestUpdateReadCollection(_ collection: ReadCollection) -> Maybe<Void>
    
    func requestUpdateReadLink(_ link: ReadLink) -> Maybe<Void>
    
    func requestLoadCollection(collectionID: String) -> Maybe<ReadCollection>
    
    func requestUpdateItem(_ params: ReadItemUpdateParams) -> Maybe<Void>
    
    func requestFindLinkItem(using url: String) -> Maybe<ReadLink?>
}

public protocol ReadItemOptionsRemote: AuthorizationNeed {
    
    func requestLoadReadItemCustomOrder(for collectionID: String) -> Maybe<[String]?>
    
    func requestUpdateReadItemCustomOrder(for collection: String, itemIDs: [String]) -> Maybe<Void>
}

public protocol ReadLinkMemoRemote: AuthorizationNeed {
    
    func requestLoadMemo(for linkItemID: String) -> Maybe<ReadLinkMemo?>
    
    func requestUpdateMemo(_ newValue: ReadLinkMemo) -> Maybe<Void>
    
    func requestDeleteMemo(for linkItemID: String) -> Maybe<Void>
}

// MARK: - link preview

public protocol LinkPreviewRemote {
    
    func requestLoadPreview(_ url: String) -> Maybe<LinkPreview>
}

// MARK: - item category

public protocol ItemCategoryRemote: AuthorizationNeed {
    
    func requestLoadCategories(_ ids: [String]) -> Maybe<[ItemCategory]>
    
    func requestUpdateCategories(_ categories: [ItemCategory]) -> Maybe<Void>
 
    func requestSuggestCategories(_ name: String, cursor: String?) -> Maybe<SuggestCategoryCollection>
    
    func requestLoadLastestCategories() -> Maybe<[SuggestCategory]>
}
