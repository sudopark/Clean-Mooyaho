//
//  DIContainers.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import CommonPresenting

import Domain
import DataStore
import FirebaseService


// MARK: - DIContainers

class HttpAPIImple: HttpAPI { }

final class DIContainers {
    
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
        
        let localStorage: LocalStorage = LocalStorageImple()
        
        private let dataStoreImple: SharedDataStoreServiceImple = .init()
        var dataStore: SharedDataStoreService {
            return self.dataStoreImple
        }
        
        var autoInfoManager: AuthInfoManger {
            return self.dataStoreImple
        }
    }
    
    let shared: Shared = Shared()
    
    var firebaseService: FirebaseService {
        return self.shared.firebaseServiceImple
    }
}

extension DIContainers: EmptyBuilder { }

// MARK: - Repositories

extension DIContainers {
    
    var remote: Remote {
        return self.shared.firebaseServiceImple
    }
    
    var appReposiotry: AppRepository {
        
        return AppRepository(remote: self.shared.firebaseServiceImple,
                             local: self.shared.localStorage)
    }
}

// MARK: - Usecases

extension DIContainers {
    
    var authUsecase: AuthUsecase {
        
        return AuthUsecaseImple(authRepository: self.appReposiotry,
                                socialAuthRepository: self.shared.kakaoService,
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
    
    var applicationUsecase: ApplicationUsecase {
        
        return ApplicationUsecaseImple(authUsecase: self.authUsecase,
                                       memberUsecase: self.memberUsecase,
                                       locationUsecase: self.userLocationUsecase)
    }
}
