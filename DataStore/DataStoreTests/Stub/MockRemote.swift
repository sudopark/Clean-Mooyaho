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
    
    // member
    func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateUserPresence") ?? .empty()
    }
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return self.resolve(key: "requestUpdateUserPresence") ?? .empty()
    }
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        return self.resolve(key: "requestLoadMembership") ?? .empty()
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
    
    // place
    func requesUpload(_ location: UserLocation) -> Maybe<Void> {
        return self.resolve(key: "requesUpload:location") ?? .empty()
    }
    
    func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.resolve(key: "requestLoadDefaultPlaceSuggest") ?? .empty()
    }
    
    func requestSuggestPlace(_ query: String,
                             in location: UserLocation,
                             cursor: String?) -> Maybe<SuggestPlaceResult> {
        return self.resolve(key: "requestSuggestPlace") ?? .empty()
    }
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return self.resolve(key: "requestSearchNewPlace") ?? .empty()
    }
    
    func requestRegister(new place: NewPlaceForm) -> Maybe<Place> {
        return self.resolve(key: "requestRegister:place") ?? .empty()
    }
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        return self.resolve(key: "requestLoadPlace") ?? .empty()
    }
    
    // tag
    func requestRegisterTag(_ tag: Tag) -> Maybe<Void> {
        return self.resolve(key: "requestRegisterTag") ?? .empty()
    }
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return self.resolve(key: "requestLoadPlaceCommnetTags") ?? .empty()
    }
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return self.resolve(key: "requestLoadUserFeelingTags") ?? .empty()
    }
    
    // hooray
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?> {
        return self.resolve(key: "requestLoadLatestHooray") ?? .empty()
    }
    
    func requestPublishHooray(_ newForm: NewHoorayForm,
                              withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return self.resolve(key: "requestPublishHooray") ?? .empty()
    }
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.resolve(key: "requestLoadNearbyRecentHoorays") ?? .empty()
    }
    
    func requestAckHooray(_ acks: [HoorayAckMessage]) {
        self.verify(key: "requestAckHooray")
    }
    
    func requestLoadHooray(_ id: String) -> Maybe<Hooray?> {
        return self.resolve(key: "requestLoadHooray") ?? .empty()
    }
    
    func requestLoadHoorayDetail(_ id: String) -> Maybe<HoorayDetail> {
        return self.resolve(key: "requestLoadHoorayDetail") ?? .empty()
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
    
    func requestSuggestCategories(_ name: String, cursor: String?) -> Maybe<SuggestCategoryCollection> {
        return self.resolve(key: "requestSuggestCategories") ?? .empty()
    }
    
    func requestLoadLastestCategories() -> Maybe<[SuggestCategory]> {
        return self.resolve(key: "requestLoadLastestCategories") ?? .empty()
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
    func requestShare(collection: ReadCollection) -> Maybe<SharedReadCollection> {
        return self.resolve(key: "requestShare") ?? .empty()
    }
    
    func requestStopShare(collectionID: String) -> Maybe<Void> {
        return self.resolve(key: "requestStopShare") ?? .empty()
    }
    
    func requestLoadLatestSharedCollections() -> Maybe<[SharedReadCollection]> {
        return self.resolve(key: "requestLoadLatestSharedCollections") ?? .empty()
    }
    
    func requestLoadSharedCollection(_ collectionID: String) -> Maybe<SharedReadCollection> {
        return self.resolve(key: "requestLoadSharedCollection") ?? .empty()
    }
}
