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
        
        let firebaseServiceImple = FirebaseServiceImple(httpAPI: HttpAPIImple(),
                                                        serverKey: AppEnvironment.firebaseServiceKey ?? "")
        let kakaoService: KakaoService = KakaoServiceImple()
        let locationMonirotingService: LocationMonitoringService = LocationMonitoringServiceImple()
        
        let localStorage: LocalStorage = LocalStorageImple()
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
    
    var userLocationUsecase: UserLocationUsecase {
        
        return UserLocationUsecaseImple(locationMonitoringService: self.shared.locationMonirotingService,
                                        placeRepository: self.appReposiotry)
    }
}
