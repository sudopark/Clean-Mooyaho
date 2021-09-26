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
        let locationMonirotingService: LocationMonitoringService = LocationMonitoringServiceImple()
        
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
        
        var autoInfoManager: AuthInfoManger {
            return self.dataStoreImple
        }
        
        var pushBaseMessageService: PushBaseMessageService {
            let source = self.firebaseServiceImple.receivePushMessage
            return PushBaseMessageService(pushMessageSource: source)
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
        return self.shared.pushBaseMessageService
    }
}

extension DependencyInjector: EmptyBuilder { }

// MARK: - Repositories

extension DependencyInjector {
    
    var remote: Remote {
        if AppEnvironment.isTestBuild {
            return EmptyRemote()
        } else {
            return self.shared.firebaseServiceImple
        }
    }
    
    var linkPreivewRemote: LinkPreviewRemote {
        return LinkPreviewRemoteImple()
    }
    
    var appReposiotry: AppRepository {
        
        return AppRepository(remote: self.remote,
                             linkPreviewRemote: self.linkPreivewRemote,
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
    
    var searchServiceProvider: SearchServiceProvider {
        return SearchServiceProviders.naver
    }
}

// MARK: - Usecases

extension DependencyInjector {
    
    var authUsecase: AuthUsecase {
        
        return AuthUsecaseImple(authRepository: self.appReposiotry,
                                oathServiceProviders: self.supportingOAuthServiceProviders,
                                authInfoManager: self.shared.autoInfoManager,
                                sharedDataStroeService: self.shared.dataStore)
    }
    
    var memberUsecase: MemberUsecase {
        
        return MemberUsecaseImple(memberRepository: self.appReposiotry,
                                  sharedDataService: self.shared.dataStore)
    }
    
    var userLocationUsecase: UserLocationUsecase {
        
        return UserLocationUsecaseImple(locationMonitoringService: self.shared.locationMonirotingService,
                                        placeRepository: self.appReposiotry)
    }
    
    var suggestPlaceUsecase: SuggestPlaceUsecase {
        
        return SuggestPlaceUsecaseImple(placeRepository: self.appReposiotry)
    }
    
    var applicationUsecase: ApplicationUsecase {
        
        return ApplicationUsecaseImple(authUsecase: self.authUsecase,
                                       memberUsecase: self.memberUsecase,
                                       locationUsecase: self.userLocationUsecase)
    }
    
    var hoorayUsecase: HoorayUsecase {
        
        return HoorayUsecaseImple(authInfoProvider: self.shared.dataStore,
                                  memberUsecase: self.memberUsecase,
                                  hoorayRepository: self.appReposiotry,
                                  messagingService: self.messagingService,
                                  sharedStoreService: self.shared.dataStore)
    }
    
    var searchNewPlaceUsecase: SearchNewPlaceUsecase {
        
        return SearchNewPlaceUsecaseImple(placeRepository: self.appReposiotry)
    }
    
    var registerNewPlaceUsecase: RegisterNewPlaceUsecase {
        let tags = PlaceCategoryTags.allCases.map{ $0.tag }.shuffled()
        return RegisterNewPlaceUsecaseImple(placeRepository: self.appReposiotry,
                                            categoryTags: tags)
    }
    
    var placeUsecase: PlaceUsecase {
        return PlaceUsecaseImple(placeRepository: self.appReposiotry,
                                 sharedStoreService: self.shared.dataStore)
    }
    
    var readItemUsecase: ReadItemUsecase {
        return ReadItemUsecaseImple(itemsRespoitory: self.appReposiotry,
                                    optionsRespository: self.appReposiotry,
                                    authInfoProvider: self.shared.dataStore,
                                    sharedStoreService: self.shared.dataStore)
    }
}
