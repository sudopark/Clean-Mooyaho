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
    
    func updateUserIsOnline(_ userID: String, isOnline: Bool)
    
    func updateCurrent(memberID: String,
                       updateFields: [MemberUpdateField],
                       with profile: MemberProfileImageSources?) -> Observable<UpdateMemberProfileStatus>
    
    func loadCurrentMembership() -> Maybe<MemberShip>
    
    var currentMember: Observable<Member?> { get }
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
        return self.sharedDataStoreService.fetch(.currentMember)
    }
    
    public func updateUserIsOnline(_ userID: String, isOnline: Bool) {
        self.memberRepository.requestUpdateUserPresence(userID, isOnline: isOnline)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    private func finishUpdateMember(_ memberID: String,
                                    fields: [MemberUpdateField],
                                    imageSource: ImageSource? = nil) -> Observable<UpdateMemberProfileStatus> {
        return self.memberRepository
            .requestUpdateMemberProfileFields(memberID, fields: fields, imageSource: imageSource)
            .asObservable()
            .map{ _ in UpdateMemberProfileStatus.finished }
    }
    
    public func updateCurrent(memberID: String,
                              updateFields: [MemberUpdateField],
                              with profile: MemberProfileImageSources?) -> Observable<UpdateMemberProfileStatus> {
        
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
            return self.memberRepository.requestUpdateMemberProfileFields(memberID, fields: updateFields, imageSource: nil)
                .asObservable()
                .map{ _ in UpdateMemberProfileStatus.finishedWithImageUploadFail(error) }
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
        
        if let existing: MemberShip = self.sharedDataStoreService.fetch(.membership) {
            return .just(existing)
        }
        
        guard let curent = self.fetchCurrentMember() else { return .error(ApplicationErrors.sigInNeed) }
        return self.memberRepository.requestLoadMembership(for: curent.uid)
    }
}


extension MemberUsecaseImple {
    
    public var currentMember: Observable<Member?> {
        return self.sharedDataStoreService
            .observe(SharedDataKeys.currentMember.rawValue)
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
