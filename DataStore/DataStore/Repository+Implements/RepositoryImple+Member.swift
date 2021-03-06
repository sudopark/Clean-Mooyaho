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
    var fileHandleService: FileHandleService { get }
}



// MARK: - member repository default implementation

extension MemberRepository where Self: MemberRepositoryDefImpleDependency {
    
    public func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        return self.memberRemote.requestUpdatePushToken(userID, deviceID: deviceID, newToken: newToken)
    }
    
    public func requestUploadMemberProfileImage(_ memberID: String,
                                                source: ImageUploadReqParams) -> Observable<MemberProfileUploadStatus> {
        switch source {
        case let .emoji(value):
            return .just(.completed(.emoji(value)))
            
        case let .data(data, ext, size):
            return self.memberRemote.requestUploadMemberProfileImage(memberID, data: data, ext: ext, size: size)
            
        case let .file(path, needCopyTemp, size):
            return self.uploadProfileImageFromFile(for: memberID,
                                                   path: path, withCopy: needCopyTemp, imageSize: size)
        }
    }
    
    private func uploadProfileImageFromFile(for memberID: String,
                                            path: String,
                                            withCopy: Bool,
                                            imageSize: ImageSize) -> Observable<MemberProfileUploadStatus> {
        let source = FilePath.raw(path)
        let fileURL = URL(fileURLWithPath: path)
        let ext = fileURL.pathExtension
        
        let copyFileIfNeed: () -> Maybe<FilePath> = {
            guard withCopy else { return .just(source) }
            let fileName = "\(memberID).\(ext)"
            let tempPath = FilePath.raw(FilePath.temp(fileName).absolutePath)
            return self.fileHandleService.copy(source: source, to: tempPath).map { tempPath }
        }
        let thenUpload: (FilePath) -> Observable<MemberProfileUploadStatus>
        thenUpload = { [weak self] filePath in
            guard let self = self else { return .empty() }
            return self.memberRemote
                .requestUploadMemberProfileImage(memberID,
                                                 filePath: filePath.fullPath, ext: ext,
                                                 size: imageSize)
        }
        
        return copyFileIfNeed()
            .asObservable()
            .flatMap(thenUpload)
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
