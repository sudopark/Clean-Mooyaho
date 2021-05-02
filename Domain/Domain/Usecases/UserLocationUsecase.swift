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
    
    private let locationService: LocationService
    private let locationRepository: LocationRepository
    
    public init(locationService: LocationService, locationRepository: LocationRepository) {
        self.locationService = locationService
        self.locationRepository = locationRepository
    }
    
    
    private let currentMember = BehaviorRelay<Member?>(value: nil)
    private let disposeBag = DisposeBag()
    private var locationMonitoring: Disposable?
}


// MARK: - check and request permission

extension UserLocationUsecaseImple {
    
    public func checkHasPermission() -> Maybe<LocationServiceAccessPermission> {
        return self.locationService.checkHasPermission()
    }
    
    public func requestPermission() -> Maybe<Bool> {
        return self.locationService.requestPermission()
    }
}


// MARKL - upload user location


extension UserLocationUsecaseImple {
    
    public func startUploadUserLocation(with option: LocationMonitoringOption, for member: Member) {
        self.currentMember.accept(member)
        self.locationMonitoring?.dispose()
        
        let memberID = member.uid
        let uploadLocations: (LastLocation) -> Maybe<Void> = { [weak self] lastLocation in
            guard let self = self else { return .empty() }
            let location = UserLocation(userID: memberID, lastLocation: lastLocation)
            return self.locationRepository.uploadLocation(location)
                .catchAndReturn(())
        }
        
        self.locationMonitoring = self.locationService
            .currentUserLocation
            .throttle(.milliseconds(option.throttlingInterval), latest: true, scheduler: MainScheduler.instance)
            .flatMapLatest(uploadLocations)
            .subscribe()
        
        self.locationService.startMonitoring(with: option)
    }
    
    public func stopUplocationUserLocation() {
        self.locationMonitoring?.dispose()
    }
    
    public var monitoringError: Observable<Error> {
        return self.locationService.occurError
    }
}
