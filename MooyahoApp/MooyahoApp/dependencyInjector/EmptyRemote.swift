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
}
