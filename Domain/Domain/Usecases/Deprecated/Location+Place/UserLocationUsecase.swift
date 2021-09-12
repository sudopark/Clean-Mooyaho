//
//  UserLocationUsecase.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation
import CoreLocation

import RxSwift
import RxRelay


public protocol UserLocationUsecase: AnyObject {
    
    // input
    func checkHasPermission() -> Maybe<LocationServiceAccessPermission>
    func requestPermission() -> Maybe<Bool>
    
    func fetchUserLocation() -> Maybe<LastLocation>
    
    func startUploadUserLocation(for memberID: String)
    func stopUplocationUserLocation()
    
    func convertToPlaceMark(_ coordinate: Coordinate) -> Maybe<PlaceMark>
    
    // output
    var monitoringError: Observable<Error> { get }
    var isAuthorized: Observable<Bool> { get }
}

extension UserLocationUsecase {
    
    public func fetchCurrentLocation() -> Maybe<Location> {
        
        let fetchPlaceMarkAndConvertToLocation: (LastLocation) -> Maybe<Location>
        fetchPlaceMarkAndConvertToLocation = { [weak self] lastLot in
            guard let self = self else { return .empty() }
            let coord = Coordinate(latt: lastLot.lattitude, long: lastLot.longitude)
            return self.convertToPlaceMark(coord)
                .map{ Location(coordinate: coord, placeMark: $0) }
        }
        
        return self.fetchUserLocation()
            .flatMap(fetchPlaceMarkAndConvertToLocation)
    }
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
        return .init(accuracy: .best, distanceFilter: 1)
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
    
    public func convertToPlaceMark(_ coordinate: Coordinate) -> Maybe<PlaceMark> {
        return Maybe.create { callback in
            
            let geoCoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latt, longitude: coordinate.long)
            geoCoder.reverseGeocodeLocation(location) { placeMarks, error in
                guard error == nil, let placeMark = placeMarks?.first else {
                    callback(.error(error ?? ApplicationErrors.invalid))
                    return
                }
                callback(.success(placeMark.convert()))
            }
            
            return Disposables.create()
        }
    }
}


extension CLPlacemark {
    
    public func convert() -> PlaceMark {
        
        return .init(city: self.administrativeArea,
                     placeName: self.name,
                     subLocality: self.subLocality,
                     thoroughfare: self.thoroughfare,
                     locality: self.locality,
                     postalCode: self.postalCode)
    }
}
