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
import DataStore


final class EmptyRemote: Remote {
    
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
    
    func requestLoadHoorayDetail(_ id: String) -> Maybe<HoorayDetail> {
        return .empty()
    }
    
    func requestLoadHooray(_ id: String) -> Maybe<Hooray?> {
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
    
    func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void> {
        return .empty()
    }
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        return .empty()
    }
    
    func requesUpload(_ location: UserLocation) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return .empty()
    }
    
    func requestSuggestPlace(_ query: String, in location: UserLocation, cursor: String?) -> Maybe<SuggestPlaceResult> {
        return .empty()
    }
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation, of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return .empty()
    }
    
    func requestRegister(new place: NewPlaceForm) -> Maybe<Place> {
        return .empty()
    }
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        return .empty()
    }
    
    func requestRegisterTag(_ tag: Tag) -> Maybe<Void> {
        return .empty()
    }
    
    func requestLoadPlaceCommnetTags(_ keyword: String, cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return .empty()
    }
    
    func requestLoadUserFeelingTags(_ keyword: String, cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return .empty()
    }
    
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?> {
        return .empty()
    }
    
    func requestPublishHooray(_ newForm: NewHoorayForm, withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return .empty()
    }
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return .empty()
    }
    
    func requestAckHooray(_ acks: [HoorayAckMessage]) { }
    
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
