//
//  LocalStorageImple+Auth.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain


extension LocalStorageImple {
    
    public func fetchCurrentAuth() -> Maybe<Auth?> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            
            self.encryptedStorage.fetchDecodable(EncrytedDataKeys.auth.rawValue)
                .runMaybeCallback(callback)
            
            return Disposables.create()
        }
    }
    
    public func fetchCurrentMember() -> Maybe<Member?> {
        
        let currentMemberID = self.fetchCurrentAuth().map{ $0?.userID }
        let thenFetchMember: (String?) -> Maybe<Member?> = { [weak self] memberID in
            guard let memberID = memberID else { return .just(nil) }
            guard let storage = self?.dataModelStorage
            else {
                return .error(LocalErrors.localStorageNotReady)
            }
            return storage.fetchMember(for: memberID)
        }
        return currentMemberID
            .flatMap(thenFetchMember)
    }
    
    public func saveSignedIn(auth: Auth) -> Maybe<Void> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            
            let auth = auth |> \.isSignIn .~ true
            self.encryptedStorage.saveEncodable(EncrytedDataKeys.auth.rawValue, value: auth)
                .runMaybeCallback(callback)
            
            return Disposables.create()
        }
    }
    
    public func saveSignedIn(member: Member) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.save(member: member)
    }
}


extension Auth: Codable {
    
    enum CodingKeys: String, CodingKey {
        case userID = "uid"
        case isSignIn = "is_sign_in"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.userID, forKey: .userID)
        try container.encode(self.isSignIn, forKey: .isSignIn)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(userID: try container.decode(String.self, forKey: .userID))
        self.isSignIn = (try? container.decode(Bool.self, forKey: .isSignIn)) ?? false
    }
}
