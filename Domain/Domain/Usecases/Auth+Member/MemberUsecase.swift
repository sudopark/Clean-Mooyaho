//
//  MemberUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


public enum UpdateMemberProfileStatus: Equatable {
    
    case pending
    case updating(_ percent: Float)
    case finishedWithImageUploadFail(_ error: Error)
    case finished
    
    public static func == (lhs: UpdateMemberProfileStatus, rhs: UpdateMemberProfileStatus) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending): return true
        case let (.updating(p1), .updating(p2)): return p1 == p2
        case (.finishedWithImageUploadFail, .finishedWithImageUploadFail): return true
        case (.finished, .finished): return true
        default: return false
        }
    }
}

// MARK: - MemberUsecase

public protocol MemberUsecase {
    
    func fetchCurrentMember() -> Member?
    
    func updateUserIsOnline(_ userID: String, deviceID: String, isOnline: Bool)
    
    func updatePushToken(_ userID: String, deviceID: String, newToken: String)
    
    func refreshMembers(_ ids: [String])
    
    func loadMembers(_ ids: [String]) -> Maybe<[Member]>
    
    func updateCurrent(memberID: String,
                       updateFields: [MemberUpdateField],
                       with profile: ImageUploadReqParams?) -> Observable<UpdateMemberProfileStatus>
    
    func loadCurrentMembership() -> Maybe<MemberShip>
    
    var currentMember: Observable<Member?> { get }
    
    func members(for ids: [String]) -> Observable<[String: Member]>
}


// MARK: - MemberUsecaseImple

public final class MemberUsecaseImple: MemberUsecase {
    
    private let disposeBag: DisposeBag = .init()
    private let memberRepository: MemberRepository
    private let sharedDataStoreService: SharedDataStoreService
    
    public init(memberRepository: MemberRepository,
                sharedDataService: SharedDataStoreService) {
        
        self.memberRepository = memberRepository
        self.sharedDataStoreService = sharedDataService
    }
}


extension MemberUsecaseImple {
    
    public func fetchCurrentMember() -> Member? {
        return self.sharedDataStoreService.fetch(Member.self, key: .currentMember)
    }
    
    public func updateUserIsOnline(_ userID: String, deviceID: String, isOnline: Bool) {
        self.memberRepository.requestUpdateUserPresence(userID, deviceID: deviceID, isOnline: isOnline)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func updatePushToken(_ userID: String, deviceID: String, newToken: String) {
        self.memberRepository.requestUpdatePushToken(userID, deviceID: deviceID, newToken: newToken)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func finishUpdateMember(_ memberID: String,
                                    fields: [MemberUpdateField],
                                    thumbnail: MemberThumbnail? = nil,
                                    imageUploadFail: Error? = nil) -> Observable<UpdateMemberProfileStatus> {
        
        let shareUpdatedMember: (Member) -> Void = { [weak self] member in
            self?.sharedDataStoreService
                .update(Member.self, key: SharedDataKeys.currentMember.rawValue, value: member)
            self?.sharedDataStoreService
                .update([String: Member].self, key: SharedDataKeys.memberMap.rawValue) { dict in
                    return (dict ?? [:]).merging([member.uid: member], uniquingKeysWith: { $1 })
                }
        }
        
        return self.memberRepository
            .requestUpdateMemberProfileFields(memberID, fields: fields, thumbnail: thumbnail)
            .do(onNext: shareUpdatedMember)
            .asObservable()
            .map { _ in
                if let uploadImageError = imageUploadFail {
                    return UpdateMemberProfileStatus.finishedWithImageUploadFail(uploadImageError)
                } else {
                    return UpdateMemberProfileStatus.finished
                }
            }
    }
    
    public func updateCurrent(memberID: String,
                              updateFields: [MemberUpdateField],
                              with profile: ImageUploadReqParams?) -> Observable<UpdateMemberProfileStatus> {
        
        let isRequestParametersEmpty = updateFields.isEmpty && profile == nil
        guard isRequestParametersEmpty == false else {
            return .error(ApplicationErrors.invalid)
        }
        
        // check valid params
        guard let profile = profile else {
            return self.finishUpdateMember(memberID, fields: updateFields)
        }
    
        let uploadImage = self.memberRepository.requestUploadMemberProfileImage(memberID, source: profile)
        
        let thenUpdateFieldOrBypassEvent: (MemberProfileUploadStatus) -> Observable<UpdateMemberProfileStatus>
        thenUpdateFieldOrBypassEvent = { [weak self] uploadStatus in
            guard let self = self else { return .empty() }
            switch uploadStatus {
            case let .uploading(percent):
                return .just(.updating(percent))
            case let .completed(thumbnail):
                return self.finishUpdateMember(memberID, fields: updateFields, thumbnail: thumbnail)
            }
        }
        
        let errorthenJustUpdateFields: (Error) -> Observable<UpdateMemberProfileStatus> = { [weak self] error in
            guard let self = self else { return .empty() }
            return self.finishUpdateMember(memberID, fields: updateFields, imageUploadFail: error)
        }
        
        return uploadImage
            .flatMap(thenUpdateFieldOrBypassEvent)
            .startWith(.pending)
            .catch(errorthenJustUpdateFields)
    }
    
    
//    public func loadNearbyUsers(at location: Coordinate) -> Maybe<[UserPresence]> {
//        return self.memberRepository
//            .requestLoadNearbyUsers(at: location)
//    }
    
    public func loadCurrentMembership() -> Maybe<MemberShip> {
        
        if let existing = self.sharedDataStoreService.fetch(MemberShip.self, key: .membership) {
            return .just(existing)
        }
        
        guard let curent = self.fetchCurrentMember() else { return .error(ApplicationErrors.sigInNeed) }
        return self.memberRepository.requestLoadMembership(for: curent.uid)
    }
    
    public func refreshMembers(_ ids: [String]) {
        self.loadMembers(ids)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}


extension MemberUsecaseImple {
    
    public var currentMember: Observable<Member?> {
        return self.sharedDataStoreService
            .observeWithCache(Member.self, key: SharedDataKeys.currentMember.rawValue)
    }
    
    public func loadMembers(_ ids: [String]) -> Maybe<[Member]> {
        
        let updateOnStore: ([Member]) -> Void = { [weak self] members in
            self?.appendMemberInfoOnSharedStore(members)
        }
        
        return self.memberRepository.requestLoadMembers(ids)
            .do(onNext: updateOnStore)
    }
    
    public func members(for ids: [String]) -> Observable<[String: Member]> {

        let localFetching: ([String]) -> Maybe<[Member]> = { [weak self] ids in
            return self?.memberRepository.fetchMembers(ids) ?? .empty()
        }
        let remoteLoading: ([String]) -> Maybe<[Member]> = { [weak self] ids in
            return self?.memberRepository.requestLoadMembers(ids) ?? .empty()
        }
        
        let key = SharedDataKeys.memberMap.rawValue
        let members: Observable<[Member]> = self.sharedDataStoreService
            .observeValuesWithSetup(ids: ids, sharedKey: key, disposeBag: self.disposeBag,
                                    idSelector: { $0.uid },
                                    localFetchinig: localFetching,
                                    remoteLoading: remoteLoading)
        return members.map { ms in
            return ms.reduce(into: [String: Member]()) { $0[$1.uid] = $1 }
        }
    }
    
    private func appendMemberInfoOnSharedStore(_ members: [Member]) {
        let storeKey = SharedDataKeys.memberMap.rawValue
        self.sharedDataStoreService.update([String: Member].self, key: storeKey) {
            return members.reduce($0 ?? [:]) { $0 |> key($1.uid) .~ $1 }
        }
    }
}


private extension MemberProfileUploadStatus {
    
    var uploadingPercent: Float? {
        guard case let .uploading(percent) = self else { return nil }
        return percent
    }
}
