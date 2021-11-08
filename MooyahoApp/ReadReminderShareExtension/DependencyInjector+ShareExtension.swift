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
        var dataStore: SharedDataStoreService {
            return self.dataStoreImple
        }
        
        let firebaseServiceImple = FirebaseServiceImple(httpAPI: HttpAPIImple(),
                                                        serverKey: ShareExtensionEnvironment.firebaseServiceKey ?? "")
        
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
    
    var readItemUsecase: ReadItemUsecase {
        return ReadItemUsecaseImple(itemsRespoitory: self.appReposiotry,
                                    previewRepository: self.appReposiotry,
                                    optionsRespository: self.appReposiotry,
                                    authInfoProvider: self.shared.dataStore,
                                    sharedStoreService: self.shared.dataStore,
                                    clipBoardService: UIPasteboard.general,
                                    readItemUpdateEventPublisher: nil)
    }
    
    var categoryUsecase: ReadItemCategoryUsecase {
        return ReadItemCategoryUsecaseImple(repository: self.appReposiotry,
                                            sharedService: self.shared.dataStore)
    }
    
    var suggestCategoryUsecase: SuggestCategoryUsecase {
        return SuggestCategoryUsecaseImple(repository: self.appReposiotry)
    }
    
    var remindUsecase: ReadRemindUsecase {
        return ReadRemindUsecaseImple(authInfoProvider: self.shared.dataStore,
                                      sharedStore: self.shared.dataStore,
                                      readItemUsecase: self.readItemUsecase,
                                      messagingService: self.readRemindMessagingService)
    }
}
