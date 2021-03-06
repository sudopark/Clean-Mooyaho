//
//  MemberRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/20.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestUpdatePushToken(_ userID: String, deviceID: String, newToken: String) -> Maybe<Void> {
        typealias Key = UserDeviceMappingKey
        let updating: JSON = [
            Key.userID.rawValue: userID,
            Key.token.rawValue: newToken,
            Key.platform.rawValue: UserDevices.Platform.ios.rawValue,
        ]
        return self.update(docuID: userID, newFields: updating, at: .userDevice)
    }
    
    public func requestUploadMemberProfileImage(_ memberID: String,
                                                data: Data, ext: String,
                                                size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        
        let fileName = "\(memberID).\(ext)"
        let fileRef = self.storage.ref(for: .images(.memberPfoile(fileName)))
        return self.storage.upload(fileRef, data: data)
            .map{ $0.asMemberProfileUploadStatus(size) }
    }
    
    public func requestUploadMemberProfileImage(_ memberID: String,
                                                filePath: String, ext: String,
                                                size: ImageSize) -> Observable<MemberProfileUploadStatus> {
        let fileName = "\(memberID).\(ext)"
        let fileRef = self.storage.ref(for: .images(.memberPfoile(fileName)))
        return self.storage.upload(fileRef, filePath: filePath)
            .map{ $0.asMemberProfileUploadStatus(size) }
    }
    
    public func requestUpdateMemberProfileFields(_ memberID: String,
                                                 fields: [MemberUpdateField],
                                                 thumbnail: MemberThumbnail?) -> Maybe<Member> {
        typealias Key = MemberMappingKey
        var updating: JSON = fields.reduce(into: [:]) { dict, field in
            switch field {
            case let .nickName(newValue):
                dict[Key.nicknanme] = newValue
            case let .introduction(newValue) where newValue == nil:
                dict[Key.introduction] = FieldValue.delete()
            case let .introduction(newValue) where newValue != nil:
                dict[Key.introduction] = newValue
            default: break
            }
        }
        updating[Key.icon] = thumbnail?.asJSON()
        let updateMember: Maybe<Void> = updating.isEmpty
            ? .just()
            : self.update(docuID: memberID, newFields: updating, at: .member)
        
        let thenLoadMember: () -> Maybe<Member> = { [weak self] in
            guard let self = self else { return .empty() }
            let loadedMember: Maybe<Member?> = self.load(docuID: memberID, in: .member)
            return loadedMember.compactMap { member in
                guard let member = member else { throw RemoteErrors.loadFail("Member", reason: nil )}
                return member
            }
        }
        
        return updateMember
            .flatMap(thenLoadMember)
    }
    
    
    public func requestLoadMember(_ ids: [String]) -> Maybe<[Member]> {
        
        typealias Key = MemberMappingKey
        
        let collectionRef = self.fireStoreDB.collection(.member)
        
        let idChunks = ids.slice(by: 10).filter { $0.isNotEmpty }
        guard idChunks.isNotEmpty else {
            return .just([])
        }
        
        let queries = idChunks.map { collectionRef.whereField(FieldPath.documentID(), in: $0) }
        return self.loadAll(queries: queries)
            .asMaybe()
    }
}


private extension FirebaseFileUploadEvents {
    
    func asMemberProfileUploadStatus(_ imageSize: ImageSize) -> MemberProfileUploadStatus {
        
        switch self {
        case let .uploading(percent): return .uploading(Float(percent))
        case let .completed(url):
            let source = ImageSource(path: url.absoluteString, size: imageSize)
            return .completed(.imageSource(source))
        }
    }
}
