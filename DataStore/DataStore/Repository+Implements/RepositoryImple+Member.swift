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
    
}



// MARK: - member repository default implementation

extension MemberRepository where Self: MemberRepositoryDefImpleDependency {
    
    
    public func requestUpdateUserPresence(_ userID: String, isOnline: Bool) -> Maybe<Void> {
        return self.memberRemote.requestUpdateUserPresence(userID, isOnline: isOnline)
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
            
        case let .data(data, ext):
            return self.memberRemote.requestUploadMemberProfileImage(memberID, data: data, ext: ext)
            
        case let .file(path, needCopyTemp): return .empty()
        }
    }
    
    public func requestUpdateMemberProfileFields(_ memberID: String,
                                                 fields: [MemberUpdateField],
                                                 imageSource: ImageSource?) -> Maybe<Void> {
        return self.memberRemote
            .requestUpdateMemberProfileFields(memberID, fields: fields, imageSource: imageSource)
    }
}
