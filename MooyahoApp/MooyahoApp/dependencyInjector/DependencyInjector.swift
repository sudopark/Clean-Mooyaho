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
            return KakaoOAuthRemoteImple(path: AppEnvironment.kakaoSignInAPIPath ?? "",
                                         api: HttpAPIImple())
        }
        
        let firebaseServiceImple = FirebaseServiceImple(httpAPI: HttpAPIImple(),
                                                        serverKey: AppEnvironment.firebaseServiceKey ?? "",
                                                        previewRemote: LinkPreviewRemoteImple())
        let kakaoService: KakaoService = KakaoServiceImple(remote: kakaoOAuthRemote)
        
        let localStorage: LocalStorage = {
            let encryptedStorage = EncryptedStorageImple(identifier: AppEnvironment.encryptedStorageIdentifier)
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
        
        lazy var sharedEventService: SharedEventService = {
            return SharedEventServiceImple()
        }()
        
        var authInfoManager: AuthInfoManger {
            return self.dataStoreImple
        }
        
        let crashLogger: CrashLogger = FirebaseCrashLogger()
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
    
    var suggestQueryEngine: SuggestQueryEngine {
        return  SuggestQueryEngineImple()
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
    
    private var appleLoginService: OAuthServiceProvider {
        return AppleLoginService()
    }
    
    var supportingOAuthServiceProviders: [OAuthServiceProvider] {
        return [
            self.shared.kakaoService,
            GoggleSignInServiceImple(),
            self.appleLoginService
        ]
    }
    
    var imagePickPermissionCheckService: ImagePickPermissionCheckService {
        return ImagePickPermissionCheckServiceImple()
    }
    
    var deviceInfoService: DeviceInfoService {
        return IOSDeviceInfoService()
    }
}

// MARK: - Usecases

extension DependencyInjector {
    
    var authUsecase: AuthUsecase {
        
        let repository = self.appReposiotry
        return AuthUsecaseImple(authRepository: repository,
                                oathServiceProviders: self.supportingOAuthServiceProviders,
                                authInfoManager: self.shared.authInfoManager,
                                sharedDataStroeService: self.shared.dataStore,
                                searchReposiotry: repository,
                                memberRepository: repository,
                                sharedEventService: self.shared.sharedEventService)
    }
    
    var memberUsecase: MemberUsecase {
        
        return MemberUsecaseImple(memberRepository: self.appReposiotry,
                                  sharedDataService: self.shared.dataStore)
    }
    
    var applicationUsecase: ApplicationUsecase {
        
        return ApplicationUsecaseImple(authUsecase: self.authUsecase,
                                       memberUsecase: self.memberUsecase,
                                       readItemUsecase: self.readItemUsecase,
                                       readItemCategoryUsecase: self.categoryUsecase,
                                       shareUsecase: self.shareItemUsecase,
                                       crashLogger: self.shared.crashLogger)
    }
    
    var readItemUsecase: ReadItemUsecase {
        return self.readItemUsecaseImple
    }
    
    var readItemUsecaseImple: ReadItemUsecaseImple {
        let respository = self.appReposiotry
        return ReadItemUsecaseImple(itemsRespoitory: respository,
                                    previewRepository: respository,
                                    optionsRespository: respository,
                                    authInfoProvider: self.shared.dataStore,
                                    sharedStoreService: self.shared.dataStore,
                                    clipBoardService: UIPasteboard.general,
                                    sharedEventService: self.shared.sharedEventService,
                                    remindMessagingService: self.readRemindMessagingService,
                                    shareURLScheme: AppEnvironment.shareScheme)
    }
    
    var readingOptionUsecase: ReadingOptionUsecase {
        return ReadingOptionUsecaseImple(
            readingOptionRepository: self.appReposiotry,
            sharedDataStore: self.shared.dataStore
        )
    }
    
    var categoryUsecase: ReadItemCategoryUsecase {
        return ReadItemCategoryUsecaseImple(repository: self.appReposiotry,
                                            sharedService: self.shared.dataStore)
    }
    
    var suggestCategoryUsecase: SuggestCategoryUsecase {
        return SuggestCategoryUsecaseImple(repository: self.appReposiotry)
    }
    
    var memoUsecase: ReadLinkMemoUsecase {
        return ReadLinkMemoUsecaseImple(repository: self.appReposiotry)
    }
    
    var userDataMigrationUsecase: UserDataMigrationUsecase {
        return UserDataMigrationUsecaseImple(migrationRepository: self.appReposiotry,
                                             shareEventService: self.shared.sharedEventService)
    }
    
    var shareItemUsecase: ShareReadCollectionUsecase & SharedReadCollectionLoadUsecase & SharedReadCollectionHandleUsecase & SharedReadCollectionUpdateUsecase {
        return ShareItemUsecaseImple(shareURLScheme: AppEnvironment.shareScheme,
                                     shareRepository: self.appReposiotry,
                                     authInfoProvider: self.shared.authInfoManager,
                                     sharedDataService: self.shared.dataStore)
    }
    
    var sharedCollectionPagingUsecase: SharedReadCollectionPagingUsecase {
        return SharedReadCollectionPagingUsecaseImple(repository: self.appReposiotry,
                                                      sharedDataStoreService: self.shared.dataStore)
    }
    
    var feedbackUsecase: FeedbackUsecase {
        return FeedbackUsecaseImple(authProvider: self.shared.dataStore,
                                    deviceInfoService: self.deviceInfoService,
                                    helpRepository: self.appReposiotry)
    }
}


// MRAK: - view builders

extension DependencyInjector {
    
    var oauthSignInButtonBuilder: OAuthSignInButtonBuildable {
        
        return OAuthSignInButonBuilder {
            GoogleSignInButtonBuilder().makeButton() as? SignInButton
        }
    }
}
