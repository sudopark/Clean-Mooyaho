//
//  RepositoryImple+Member.swift
//  DataStore
//
//  Created by sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol MemberRepositoryDefImpleDependency {
    
    var memberRemote: MemberRemote { get }
    var memberLocal: MemberLocalStorage { get}
    var disposeBag: DisposeBag { get }
}



// MARK: - member repository default implementation

extension MemberRepository where Self: MemberRepositoryDefImpleDependency {
    
    
    public func requestUpdateUserPresence(_ userID: String, deviceID: String, isOnline: Bool) -> Maybe<Void> {
        return self.memberRemote.requestUpdateUserPresence(userID, deviceID: deviceID, isOnline: isOnline)
    }
    
    public func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return self.memberRemote.requestUpdatePushToken(userID, deviceID: deviceID, newToken: newToken)
    }
    
    public func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        // TODO: implement needs
        return .just(MemberShip())
    }
    
    public func requestUploadMemberProfileImage(_ memberID: String,
                                                source: ImageUploadReqParams) -> Observable<MemberProfileUploadStatus> {
        switch source {
        case let .emoji(value):
            return .just(.completed(.emoji(value)))
            
        case let .data(data, ext, size):
            return self.memberRemote.requestUploadMemberProfileImage(memberID, data: data, ext: ext, size: size)
            
        case .file: return .empty()
        }
    }
    
    public func requestUpdateMemberProfileFields(_ memberID: String,
                                                 fields: [MemberUpdateField],
                                                 thumbnail: MemberThumbnail?) -> Maybe<Member> {
        
        let thenUpdateLocal: (Member) -> Void = { [weak self] member in
            guard let self = self else { return }
            self.memberLocal.updateCurrentMember(member)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        return self.memberRemote
            .requestUpdateMemberProfileFields(memberID, fields: fields, thumbnail: thumbnail)
            .do(onNext: thenUpdateLocal)
    }
    
    public func fetchMembers(_ ids: [String]) -> Maybe<[Member]> {
        return self.memberLocal.fetchMembers(ids)
    }
    
    public func requestLoadMembers(_ ids: [String]) -> Maybe<[Member]> {
        
        let loadMembers = self.memberRemote.requestLoadMember(ids)
        let thenUpdateCache: ([Member]) -> Void = { [weak self] members in
            guard let self = self else { return }
            self.memberLocal.saveMembers(members)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        return loadMembers
            .do(onNext: thenUpdateCache)
    }
}
