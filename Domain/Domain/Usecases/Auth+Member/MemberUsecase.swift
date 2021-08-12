//
//  MemberUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


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
                                    imageSource: ImageSource? = nil,
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
            .requestUpdateMemberProfileFields(memberID, fields: fields, imageSource: imageSource)
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
            case let .completed(source):
                return self.finishUpdateMember(memberID, fields: updateFields, imageSource: source)
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
        
        let updateStore: ([Member]) -> Void = { [weak self] members in
            let memberMap = members.reduce(into: [String: Member]()) { $0[$1.uid] = $1 }
            self?.addMembersOnStore(memberMap)
        }
        
        self.memberRepository.requestLoadMembers(ids)
            .subscribe(onSuccess: updateStore)
            .disposed(by: self.disposeBag)
    }
    
    public func loadMembers(_ ids: [String]) -> Maybe<[Member]> {
        
        typealias MemberMap = [String: Member]
        
        let appendMembersOnCacheIfNeed: (MemberMap) -> Maybe<MemberMap>
        appendMembersOnCacheIfNeed = { [weak self] preparedMemberMap in
            guard let self = self else { return .empty() }
            return self.loadAndAppendMembersIfNeed(preparedMemberMap, total: ids,
                                                   loading: self.memberRepository.fetchMembers(_:))
        }
        let appendMembersFromRemoteIfNeed: (MemberMap) -> Maybe<MemberMap>
        appendMembersFromRemoteIfNeed = { [weak self] prepareMap in
            guard let self = self else { return .empty() }
            return self.loadAndAppendMembersIfNeed(prepareMap, total: ids,
                                                   loading: self.memberRepository.requestLoadMembers(_:))
        }
        
        let updateStore: (MemberMap) -> Void = { [weak self] memberMap in
            self?.addMembersOnStore(memberMap)
        }
        
        let asArray: (MemberMap) -> [Member] = { memberMap in
            return ids.compactMap{ memberMap[$0] }
        }
        
        return self.getMembersOnStore(ids)
            .flatMap(appendMembersOnCacheIfNeed)
            .flatMap(appendMembersFromRemoteIfNeed)
            .do(onNext: updateStore)
            .map(asArray)
    }
    
    private func getMembersOnStore(_ ids: [String]) -> Maybe<[String: Member]> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            let memberMap = self.sharedDataStoreService.fetch([String: Member].self, key: .memberMap) ?? [:]
            let memberOnMemory = ids.reduce(into: [String: Member]()) { acc, id in
                memberMap[id].whenExists { acc[id] = $0 }
            }
            callback(.success(memberOnMemory))
            return Disposables.create()
        }
    }
    
    private func loadAndAppendMembersIfNeed(_ prepared: [String: Member],
                                            total: [String],
                                            loading: @escaping ([String]) -> Maybe<[Member]>) -> Maybe<[String: Member]> {
        let requireIDs = total.filter{ prepared[$0] == nil }
        guard requireIDs.isNotEmpty else { return .just(prepared) }
        
        return loading(requireIDs)
            .map{ prepared.append($0) }
    }
    
    private func addMembersOnStore(_ newDict: [String: Member]) {
        let key = SharedDataKeys.memberMap.rawValue
        self.sharedDataStoreService.update([String: Member].self, key: key) {  dict in
            return (dict ?? [:]).merging(newDict, uniquingKeysWith: { $1} )
        }
    }
}


extension MemberUsecaseImple {
    
    public var currentMember: Observable<Member?> {
        return self.sharedDataStoreService
            .observe(Member.self, key: SharedDataKeys.currentMember.rawValue)
    }
    
    
    public func members(for ids: [String]) -> Observable<[String: Member]> {
        
        let filtering: ([String: Member]) -> [String: Member] = { memberMap in
            return ids.reduce(into: [String: Member]()) { acc, id in
                memberMap[id].whenExists{ acc[id] = $0 }
            }
        }
        let key = SharedDataKeys.memberMap.rawValue
        let memberMap = self.sharedDataStoreService.observeWithCache([String: Member].self, key: key)
            .compactMap{ $0 }
        
        return memberMap.map(filtering)
    }
}


private extension MemberProfileUploadStatus {
    
    var uploadingPercent: Float? {
        guard case let .uploading(percent) = self else { return nil }
        return percent
    }
    
    var completedSource: ImageSource? {
        guard case let .completed(source) = self else { return nil }
        return source
    }
}


private extension Dictionary where Key == String, Value == Member {
    
    func append(_ members: [Member]) -> Dictionary {
        var newDict = self
        members.forEach {
            newDict[$0.uid] = $0
        }
        return newDict
    }
}
