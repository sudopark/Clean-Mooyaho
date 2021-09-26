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
    private let linkPreviewRemote: LinkPreviewRemote
    private let local: LocalStorage
    public let disposeBag: DisposeBag = DisposeBag()
    
    public init(remote: Remote,
                linkPreviewRemote: LinkPreviewRemote,
                local: LocalStorage) {
        self.remote = remote
        self.linkPreviewRemote = linkPreviewRemote
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
    
    public var memberLocal: MemberLocalStorage {
        return self.local
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


extension AppRepository: HoorayRepository, HoorayRepositoryDefImpleDependency {
    
    public var hoorayRemote: HoorayRemote {
        return self.remote
    }
    
    public var hoorayLocal: HoorayLocalStorage {
        return self.local
    }
}

extension AppRepository: ReadItemRepository, ReadItemRepositryDefImpleDependency {
    
    public var readItemRemote: ReadItemRemote {
        return self.remote
    }
    
    public var readItemLocal: ReadItemLocalStorage {
        return self.local
    }
}

extension AppRepository: ReadItemOptionsRepository, ReadItemOptionReposiotryDefImpleDependency {
    
    public var readItemOptionLocal: ReadItemOptionsLocalStorage {
        return self.local
    }
}

extension AppRepository: LinkPreviewRepository, LinkPreviewrepositoryDefImpleDependency {
    
    public var previewRemote: LinkPreviewRemote {
        return self.linkPreviewRemote
    }
    
    public var previewCache: LinkPreviewCacheStorage {
        return self.local
    }
}
