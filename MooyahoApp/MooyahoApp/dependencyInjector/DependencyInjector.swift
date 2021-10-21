//
//  DependencyInjector.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain
import CommonPresenting
import DataStore
import FirebaseService


// MARK: - DIContainers

class HttpAPIImple: HttpAPI { }

final class DependencyInjector {
    
    class Shared {
        
        fileprivate init() {}
        
        private static var kakaoOAuthRemote: KakaoOAuthRemote {
            return KakaoOAuthRemoteImple(path: AppEnvironment.legacyAPIPath ?? "",
                                         api: HttpAPIImple())
        }
        
        let firebaseServiceImple = FirebaseServiceImple(httpAPI: HttpAPIImple(),
                                                        serverKey: AppEnvironment.firebaseServiceKey ?? "")
        let kakaoService: KakaoService = KakaoServiceImple(remote: kakaoOAuthRemote)
        
        let localStorage: LocalStorage = {
            let encryptedStorage = EncryptedStorageImple(identifier: "clean.mooyaho")
            let dataModelStorage = DataModelStorageImple(dbPath: AppEnvironment.dataModelDBPath)
            return LocalStorageImple(encryptedStorage: encryptedStorage,
                                     environmentStorage: UserDefaults.standard,
                                     dataModelStorage: dataModelStorage)
        }()
        
        private let dataStoreImple: SharedDataStoreServiceImple = .init()
        var dataStore: SharedDataStoreService {
            return self.dataStoreImple
        }
        
        var authInfoManager: AuthInfoManger {
            return self.dataStoreImple
        }
    }
    
    let shared: Shared = Shared()
    
    var firebaseService: FirebaseService {
        return self.shared.firebaseServiceImple
    }
    
    var fcmService: FCMService {
        return self.shared.firebaseServiceImple
    }
    
    var messagingService: MessagingService {
        return self.shared.firebaseServiceImple
    }
    
    var readRemindMessagingService: ReadRemindMessagingService {
        return self.shared.firebaseServiceImple
    }
}

extension DependencyInjector: EmptyBuilder { }

// MARK: - Repositories

extension DependencyInjector {
    
    var remote: Remote {
        if AppEnvironment.isTestBuild {
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
    
    var supportingOAuthServiceProviders: [OAuthServiceProvider] {
        return [
            self.shared.kakaoService
        ]
    }
    
    var imagePickPermissionCheckService: ImagePickPermissionCheckService {
        return ImagePickPermissionCheckServiceImple()
    }
}

// MARK: - Usecases

extension DependencyInjector {
    
    var authUsecase: AuthUsecase {
        
        return AuthUsecaseImple(authRepository: self.appReposiotry,
                                oathServiceProviders: self.supportingOAuthServiceProviders,
                                authInfoManager: self.shared.authInfoManager,
                                sharedDataStroeService: self.shared.dataStore)
    }
    
    var memberUsecase: MemberUsecase {
        
        return MemberUsecaseImple(memberRepository: self.appReposiotry,
                                  sharedDataService: self.shared.dataStore)
    }
    
    var applicationUsecase: ApplicationUsecase {
        
        return ApplicationUsecaseImple(authUsecase: self.authUsecase,
                                       memberUsecase: self.memberUsecase)
    }
    
    var readItemUsecase: ReadItemUsecase {
        return ReadItemUsecaseImple(itemsRespoitory: self.appReposiotry,
                                    previewRepository: self.appReposiotry,
                                    optionsRespository: self.appReposiotry,
                                    authInfoProvider: self.shared.dataStore,
                                    sharedStoreService: self.shared.dataStore)
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
                                      reminderRepository: self.appReposiotry,
                                      messagingService: self.readRemindMessagingService)
    }
}
