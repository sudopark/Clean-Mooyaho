//
//  DependencyInjector.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

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
            encryptedStorage.setupSharedGroup(AppEnvironment.groupID)
            
            let defaultPath = AppEnvironment.dataModelDBPath()
            let makeAnonymousStorage: () -> DataModelStorage = {
                return DataModelStorageImple(dbPath: defaultPath)
            }
            let makeUserStorage: (String) -> DataModelStorage = {
                let path = AppEnvironment.dataModelDBPath(for: $0)
                return DataModelStorageImple(dbPath: path)
            }
            let gateway = DataModelStorageGatewayImple(anonymousStoragePath: defaultPath,
                                                       makeAnonymousStorage: makeAnonymousStorage,
                                                       makeUserStorage: makeUserStorage)
            
            let envStore: UserDefaults = UserDefaults(suiteName: AppEnvironment.groupID) ?? .standard
            return LocalStorageImple(encryptedStorage: encryptedStorage,
                                     environmentStorage: envStore,
                                     dataModelGateway: gateway)
        }()
        
        private let dataStoreImple: SharedDataStoreServiceImple = .init()
        var dataStore: SharedDataStoreService {
            return self.dataStoreImple
        }
        
        var authInfoManager: AuthInfoManger {
            return self.dataStoreImple
        }
        
        fileprivate let readItemUpdateSubject = PublishSubject<ReadItemUpdateEvent>()
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
    
    var readItemUpdateEventPublisher: PublishSubject<ReadItemUpdateEvent> {
        return self.shared.readItemUpdateSubject
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
        return self.readItemUsecaseImple
    }
    
    var readItemUsecaseImple: ReadItemUsecaseImple {
        return ReadItemUsecaseImple(itemsRespoitory: self.appReposiotry,
                                    previewRepository: self.appReposiotry,
                                    optionsRespository: self.appReposiotry,
                                    authInfoProvider: self.shared.dataStore,
                                    sharedStoreService: self.shared.dataStore,
                                    clipBoardService: UIPasteboard.general,
                                    readItemUpdateEventPublisher: self.readItemUpdateEventPublisher)
    }
    
    var categoryUsecase: ReadItemCategoryUsecase {
        return ReadItemCategoryUsecaseImple(repository: self.appReposiotry,
                                            sharedService: self.shared.dataStore)
    }
    
    var suggestCategoryUsecase: SuggestCategoryUsecase {
        return SuggestCategoryUsecaseImple(repository: self.appReposiotry)
    }
    
    private var remindUsecaseImple: ReadRemindUsecaseImple {
        return ReadRemindUsecaseImple(authInfoProvider: self.shared.dataStore,
                                      sharedStore: self.shared.dataStore,
                                      readItemUsecase: self.readItemUsecase,
                                      messagingService: self.readRemindMessagingService)
    }
    
    var remindUsecase: ReadRemindUsecase {
        return self.remindUsecaseImple
    }
    
    var remindOptionUsecase: RemindOptionUsecase {
        return self.remindUsecaseImple
    }
    
    var memoUsecase: ReadLinkMemoUsecase {
        return ReadLinkMemoUsecaseImple(repository: self.appReposiotry)
    }
    
    var userDataMigrationUsecase: UserDataMigrationUsecase {
        return UserDataMigrationUsecaseImple(migrationRepository: self.appReposiotry,
                                             readItemUpdateEventPublisher: self.readItemUpdateEventPublisher)
    }
    
    var shareItemUsecase: ShareReadCollectionUsecase & SharedReadCollectionLoadUsecase & SharedReadCollectionHandleUsecase {
        return ShareItemUsecaseImple(shareRepository: self.appReposiotry,
                                     authInfoProvider: self.shared.authInfoManager,
                                     sharedDataService: self.shared.dataStore)
    }
}
