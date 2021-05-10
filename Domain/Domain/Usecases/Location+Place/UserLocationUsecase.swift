//
//  UserLocationUsecase.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


public protocol UserLocationUsecase { }


public final class UserLocationUsecaseImple {
    
    private let locationMonitoringService: LocationMonitoringService
    private let placeRepository: PlaceRepository
    
    public init(locationMonitoringService: LocationMonitoringService,
                placeRepository: PlaceRepository) {
        self.locationMonitoringService = locationMonitoringService
        self.placeRepository = placeRepository
    }
    
    private let disposeBag = DisposeBag()
    private var locationMonitoring: Disposable?
}


// MARK: - check and request permission

extension UserLocationUsecaseImple {
    
    public func checkHasPermission() -> Maybe<LocationServiceAccessPermission> {
        return self.locationMonitoringService.checkHasPermission()
    }
    
    public func requestPermission() -> Maybe<Bool> {
        return self.locationMonitoringService.requestPermission()
    }
}


// MARKL - upload user location


extension UserLocationUsecaseImple {
    
    public func startUploadUserLocation(with option: LocationMonitoringOption, for member: Member) {
        self.locationMonitoring?.dispose()
        
        let memberID = member.uid
        let uploadLocations: (LastLocation) -> Maybe<Void> = { [weak self] lastLocation in
            guard let self = self else { return .empty() }
            let location = UserLocation(userID: memberID, lastLocation: lastLocation)
            return self.placeRepository.uploadLocation(location)
                .catchAndReturn(())
        }
        
        self.locationMonitoring = self.locationMonitoringService
            .currentUserLocation
            .throttle(.milliseconds(option.throttlingInterval), latest: true, scheduler: MainScheduler.instance)
            .flatMapLatest(uploadLocations)
            .subscribe()
        
        self.locationMonitoringService.startMonitoring(with: option)
    }
    
    public func stopUplocationUserLocation() {
        self.locationMonitoring?.dispose()
    }
    
    public var monitoringError: Observable<Error> {
        return self.locationMonitoringService.occurError
    }
}
