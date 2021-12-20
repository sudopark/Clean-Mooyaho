//
//  DependencyInjector+ShareExtension.swift
//  ReadReminderShareExtension
//
//  Created by sudo.park on 2021/10/27.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


import Domain
import CommonPresenting
import DataStore
import FirebaseService


class HttpAPIImple: HttpAPI { }

final class SharedDependencyInjecttor: EmptyBuilder {
    
    class Shared {
        fileprivate init() { }
        
        private let dataStoreImple: SharedDataStoreServiceImple = .init()
        var dataStore: SharedDataStoreService & AuthInfoManger {
            return self.dataStoreImple
        }
        
        let firebaseServiceImple = FirebaseServiceImple(httpAPI: HttpAPIImple(),
                                                        serverKey: ShareExtensionEnvironment.firebaseServiceKey ?? "",
                                                        previewRemote: LinkPreviewRemoteImple())
        
        let localStorage: LocalStorage = {
            let encryptedStorage = EncryptedStorageImple(identifier: "clean.mooyaho")
            encryptedStorage.setupSharedGroup(ShareExtensionEnvironment.groupID)
            let envStore: UserDefaults = UserDefaults(suiteName: ShareExtensionEnvironment.groupID) ?? .standard
            
            let defaultPath = ShareExtensionEnvironment.dataModelDBPath()
            let makeAnonymousStorage: () -> DataModelStorage = {
                return DataModelStorageImple(dbPath: defaultPath)
            }
            let makeUserStorage: (String) -> DataModelStorage = {
                let path = ShareExtensionEnvironment.dataModelDBPath(for: $0)
                return DataModelStorageImple(dbPath: path)
            }
            let gateway = DataModelStorageGatewayImple(anonymousStoragePath: defaultPath,
                                                       makeAnonymousStorage: makeAnonymousStorage,
                                                       makeUserStorage: makeUserStorage)
            
            return LocalStorageImple(encryptedStorage: encryptedStorage,
                                     environmentStorage: envStore,
                                     dataModelGateway: gateway)
        }()
        
        var sharedEventService: SharedEventService {
            return SharedEventServiceImple()
        }
    }
    
    let shared: Shared = Shared()
}


extension SharedDependencyInjecttor {
    
    var remote: Remote {
        if ShareExtensionEnvironment.isTestBuild {
            return EmptyRemote()
        } else {
            return  RemoteImple(firebaseRemote: self.shared.firebaseServiceImple,
                                linkPreviewRemote: LinkPreviewRemoteImple())
            
        }
    }
    
    var appReposiotry: AppRepository {
        
        return AppRepository(remote: self.remote,
                             local: self.shared.localStorage)
    }
    
    var readRemindMessagingService: ReadRemindMessagingService {
        return self.shared.firebaseServiceImple
    }
}

extension SharedDependencyInjecttor {
    
    var authUsecase: AuthUsecase {
        let repository = self.appReposiotry
        return AuthUsecaseImple(authRepository: repository,
                                oathServiceProviders: [],
                                authInfoManager: self.shared.dataStore,
                                sharedDataStroeService: self.shared.dataStore,
                                searchReposiotry: repository,
                                sharedEventService: self.shared.sharedEventService)
    }
    
    var readItemUsecase: ReadItemUsecaseImple {
        let repository = self.appReposiotry
        return ReadItemUsecaseImple(itemsRespoitory: repository,
                                    previewRepository: repository,
                                    optionsRespository: repository,
                                    authInfoProvider: self.shared.dataStore,
                                    sharedStoreService: self.shared.dataStore,
                                    clipBoardService: UIPasteboard.general,
                                    sharedEventService: self.shared.sharedEventService,
                                    remindMessagingService: self.readRemindMessagingService,
                                    shareURLScheme: ShareExtensionEnvironment.shareScheme)
    }
    
    var categoryUsecase: ReadItemCategoryUsecase {
        return ReadItemCategoryUsecaseImple(repository: self.appReposiotry,
                                            sharedService: self.shared.dataStore)
    }
    
    var suggestCategoryUsecase: SuggestCategoryUsecase {
        return SuggestCategoryUsecaseImple(repository: self.appReposiotry)
    }
    
    var memberUsecase: MemberUsecase {
        return MemberUsecaseImple(memberRepository: self.appReposiotry,
                                  sharedDataService: self.shared.dataStore)
    }
}
