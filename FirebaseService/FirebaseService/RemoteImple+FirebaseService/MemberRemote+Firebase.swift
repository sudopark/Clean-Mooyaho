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
    
    public func requestUpdateUserPresence(_ userID: String, isOnline: Bool) -> Maybe<Void> {
        typealias Key = UserDeviceMappingKey
        let updating: JSON = [
            Key.isOnline.rawValue: isOnline
        ]
        return self.update(docuID: userID, newFields: updating, at: .userDevice)
    }
    
    public func requestLoadMembership(for memberID: String) -> Maybe<MemberShip> {
        // TOOD: implement needs
        return .empty()
    }
    
    public func requestUploadMemberProfileImage(_ memberID: String,
                                                data: Data, ext: String) -> Observable<MemberProfileUploadStatus> {
        
        let fileName = "\(memberID).\(ext)"
        let fileRef = self.storage.ref(for: .images(.memberPfoile(fileName)))
        return fileRef.uploadData(data)
            .map{ $0.asMemberProfileUploadStatus() }
    }
    
    public func requestUpdateMemberProfileFields(_ memberID: String,
                                                 fields: [MemberUpdateField],
                                                 imageSource: ImageSource?) -> Maybe<Void> {
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
        updating[Key.icon] = imageSource?.asJSON()
        
        return self.update(docuID: memberID, newFields: updating, at: .member)
    }
}


private extension FirebaseFileUploadEvents {
    
    func asMemberProfileUploadStatus() -> MemberProfileUploadStatus {
        
        switch self {
        case let .uploading(percent): return .uploading(Float(percent))
        case let .completed(url): return .completed(.path(url.path))
        }
    }
}
