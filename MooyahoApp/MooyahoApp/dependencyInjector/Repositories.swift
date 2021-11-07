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
    
    public init(remote: Remote,
                local: LocalStorage) {
        self.remote = remote
        self.local = local
    }
}

extension AppRepository: AuthRepository, AuthRepositoryDefImpleDependency {
    
    public var authRemote: AuthRemote {
        return self.remote
    }
    
    public var authLocal: AuthLocalStorage & DataModelStorageSwitchable {
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
    
    public var readItemOptionRemote: ReadItemOptionsRemote {
        return self.remote
    }
    
    public var readItemOptionLocal: ReadItemOptionsLocalStorage {
        return self.local
    }
}

extension AppRepository: LinkPreviewRepository, LinkPreviewrepositoryDefImpleDependency {
    
    public var previewRemote: LinkPreviewRemote {
        return self.remote
    }
    
    public var previewCache: LinkPreviewCacheStorage {
        return self.local
    }
}

extension AppRepository: ItemCategoryRepository, ItemCategoryRepositoryDefImpleDependency {
    
    public var categoryRemote: ItemCategoryRemote {
        return self.remote
    }
    
    public var categoryLocal: ItemCategoryLocalStorage {
        return self.local
    }
}


extension AppRepository: ReadLinkMemoRepository, ReadLinkMemoRepositoryDefImpleDependency {
    
    public var memoRemote: ReadLinkMemoRemote {
        return self.remote
    }
    
    public var memoLocal: ReadLinkMemoLocalStorage {
        return self.local
    }
}


extension AppRepository: UserDataMigrateRepository, UserDataMigrationRepositoryDefImpleDependency {
    
    public var migrateLocal: DataModelStorageSwitchable & UserDataMigratableLocalStorage {
        return self.local
    }
    
    public var migrateRemote: BatchUploadRemote {
        return self.remote
    }
}
