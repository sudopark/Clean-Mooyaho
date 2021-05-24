//
//  Repositories.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import DataStore
import FirebaseService


public class AppRepository {
    
    private let remote: Remote
    private let local: LocalStorage
    public let disposeBag: DisposeBag = DisposeBag()
    
    public init(remote: Remote, local: LocalStorage) {
        self.remote = remote
        self.local = local
    }
}

extension AppRepository: AuthRepository, AuthRepositoryDefImpleDependency {
    
    public var authRemote: AuthRemote {
        return self.remote
    }
    
    public var authLocal: AuthLocalStorage {
        return self.local
    }
}

extension AppRepository: MemberRepository, MemberRepositoryDefImpleDependency {
    
    public var memberRemote: MemberRemote {
        return self.remote
    }
}

extension AppRepository: PlaceRepository, PlaceRepositoryDefImpleDependency {
    
    public var placeRemote: PlaceRemote {
        return self.remote
    }
    
    public var placeLocal: PlaceLocalStorage {
        return self.local
    }
}
