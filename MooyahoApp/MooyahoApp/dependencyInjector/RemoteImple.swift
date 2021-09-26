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
import DataStore
import FirebaseService
 

final class RemoteImple: Remote {

    private let firebaseRemote: FirebaseRemote
    private let linkPreviewRemote: LinkPreviewRemote
    
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
    
    // member
    func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdateUserPresence(userID, deviceID: deviceID, isOnline: isOnline)
    }
    
    func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return self.firebaseRemote.requestUpdatePushToken(userID, deviceID: deviceID, newToken: newToken)
    }
    
    func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        return self.firebaseRemote.requestLoadMembership(for: memberID)
    }
    
    func requestUploadMemberProfileImage(_ memberID: String,
                                         data: Data, ext: String,
                                         size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        return self.firebaseRemote.requestUploadMemberProfileImage(memberID, data: data, ext: ext, size: size)
    }
    
    func requestUpdateMemberProfileFields(_ memberID: String,
                                          fields: [MemberUpdateField],
                                          thumbnail: MemberThumbnail?) -> Maybe<Member> {
        return self.firebaseRemote.requestUpdateMemberProfileFields(memberID, fields: fields, thumbnail: thumbnail)
    }
    
    func requestLoadMember(_ ids: [String]) -> Maybe<[Member]> {
        return self.firebaseRemote.requestLoadMember(ids)
    }
    
    
    // place
    func requesUpload(_ location: UserLocation) -> Maybe<Void> {
        return self.firebaseRemote.requesUpload(location)
    }
    
    func requestLoadDefaultPlaceSuggest(in location: UserLocation) -> Maybe<SuggestPlaceResult> {
        return self.firebaseRemote.requestLoadDefaultPlaceSuggest(in: location)
    }
    
    func requestSuggestPlace(_ query: String,
                             in location: UserLocation,
                             cursor: String?) -> Maybe<SuggestPlaceResult> {
        return self.firebaseRemote.requestSuggestPlace(query, in: location, cursor: cursor)
    }
    
    func requestSearchNewPlace(_ query: String, in location: UserLocation,
                               of pageIndex: Int?) -> Maybe<SearchingPlaceCollection> {
        return self.firebaseRemote.requestSearchNewPlace(query, in: location, of: pageIndex)
    }
    
    func requestRegister(new place: NewPlaceForm) -> Maybe<Place> {
        return self.firebaseRemote.requestRegister(new: place)
    }
    
    func requestLoadPlace(_ placeID: String) -> Maybe<Place> {
        return self.firebaseRemote.requestLoadPlace(placeID)
    }
    
    
    // tag
    func requestRegisterTag(_ tag: Tag) -> Maybe<Void> {
        return self.firebaseRemote.requestRegisterTag(tag)
    }
    
    func requestLoadPlaceCommnetTags(_ keyword: String,
                                     cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return self.firebaseRemote.requestLoadPlaceCommnetTags(keyword, cursor: cursor)
    }
    
    func requestLoadUserFeelingTags(_ keyword: String,
                                    cursor: String?) -> Maybe<SuggestTagResultCollection> {
        return self.firebaseRemote.requestLoadUserFeelingTags(keyword, cursor: cursor)
    }
    
    
    // hooray
    func requestLoadLatestHooray(_ memberID: String) -> Maybe<Hooray?> {
        return self.firebaseRemote.requestLoadLatestHooray(memberID)
    }
    
    func requestPublishHooray(_ newForm: NewHoorayForm,
                              withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        return self.firebaseRemote.requestPublishHooray(newForm, withNewPlace: withNewPlace)
    }
    
    func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.firebaseRemote.requestLoadNearbyRecentHoorays(at: location)
    }
    
    func requestAckHooray(_ acks: [HoorayAckMessage]) {
        return self.firebaseRemote.requestAckHooray(acks)
    }
    
    func requestLoadHooray(_ id: String) -> Maybe<Hooray?> {
        return self.firebaseRemote.requestLoadHooray(id)
    }
    
    func requestLoadHoorayDetail(_ id: String) -> Maybe<HoorayDetail> {
        return self.firebaseRemote.requestLoadHoorayDetail(id)
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
    
    
    // link preview
    func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> {
        return self.linkPreviewRemote.requestLoadPreview(url)
    }
}