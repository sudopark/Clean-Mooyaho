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


public protocol UserLocationUsecase {
    
    // input
    func checkHasPermission() -> Maybe<LocationServiceAccessPermission>
    func requestPermission() -> Maybe<Bool>
    
    func fetchUserLocation() -> Maybe<LastLocation>
    
    func startUploadUserLocation(for memberID: String)
    func stopUplocationUserLocation()
    
    // output
    var monitoringError: Observable<Error> { get }
    var isAuthorized: Observable<Bool> { get }
}


public final class UserLocationUsecaseImple: UserLocationUsecase {
    
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
    
    private var monitoringOption: LocationMonitoringOption {
        return .init(accuracy: .tenMeters, distanceFilter: 1)
    }
    
    public func fetchUserLocation() -> Maybe<LastLocation> {
        return self.locationMonitoringService.fetchLastLocation()
    }
    
    public func startUploadUserLocation(for memberID: String) {
        self.locationMonitoring?.dispose()
        
        let uploadLocations: (LastLocation) -> Maybe<Void> = { [weak self] lastLocation in
            guard let self = self else { return .empty() }
            let location = UserLocation(userID: memberID, lastLocation: lastLocation)
            return self.placeRepository.uploadLocation(location)
                .catchAndReturn(())
        }
        
        let interval = 60_000
        self.locationMonitoring = self.locationMonitoringService.currentUserLocation
            .throttle(.milliseconds(interval), latest: true, scheduler: MainScheduler.instance)
            .flatMapLatest(uploadLocations)
            .subscribe()
        
        self.locationMonitoringService.startMonitoring(with: self.monitoringOption)
    }
    
    public func stopUplocationUserLocation() {
        self.locationMonitoring?.dispose()
    }
    
    public var monitoringError: Observable<Error> {
        return self.locationMonitoringService.occurError
    }
    
    public var isAuthorized: Observable<Bool> {
        return self.locationMonitoringService.isAuthorized
    }
}
