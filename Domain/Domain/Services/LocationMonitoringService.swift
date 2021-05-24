//
//  LocationMonitoringService.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import CoreLocation



public protocol LocationMonitoringService {
    
    func checkHasPermission() -> Maybe<LocationServiceAccessPermission>
    
    func requestPermission() -> Maybe<Bool>
    
    func fetchLastLocation() -> Maybe<LastLocation>
    
    func startMonitoring(with option: LocationMonitoringOption)
    
    func stopMonitoring()
    
    var currentUserLocation: Observable<LastLocation> { get }
    
    var occurError: Observable<Error> { get }
    
    var isAuthorized: Observable<Bool> { get }
}


public final class LocationMonitoringServiceImple: NSObject, LocationMonitoringService {
    
    private var underlyingLocationManager: CLLocationManager?
    private var locationManager: CLLocationManager {
        guard let manager = underlyingLocationManager else {
            let manager = CLLocationManager()
            manager.delegate = self
            self.underlyingLocationManager = manager
            return manager
        }
        return manager
    }
    
    struct Subjects {
        let currentLocation: BehaviorSubject<LastLocation?> = .init(value: nil)
        let currentAuthorizationStatus: PublishSubject<CLAuthorizationStatus> = .init()
        let occurError = PublishSubject<Error>()
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    public override init() {
        super.init()
    }
}


extension LocationMonitoringServiceImple {
    
    public func checkHasPermission() -> Maybe<LocationServiceAccessPermission> {
        return Maybe.create { callback in
            guard CLLocationManager.locationServicesEnabled() else {
                callback(.success(.disabled))
                return Disposables.create()
            }
            
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                callback(.success(.notDetermined))
            case .restricted, .denied:
                callback(.success(.rejected))
            case .authorizedAlways, .authorizedWhenInUse, .authorized:
                callback(.success(.granted))
            @unknown default:
                callback(.completed)
            }
            return Disposables.create()
        }
    }
    
    public func requestPermission() -> Maybe<Bool> {
        
        let request: () -> Void = { [weak self] in
            self?.locationManager.requestWhenInUseAuthorization()
        }
        
        let determineIsGranted: (CLAuthorizationStatus) -> Bool = { status in
            return status == .authorizedWhenInUse || status == .authorizedAlways || status == .authorized
        }
        return self.subjects.currentAuthorizationStatus
            .map(determineIsGranted)
            .first()
            .compactMap{ $0 }
            .do(onSubscribed: request)
    }
}

extension LocationMonitoringServiceImple: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        self.subjects.currentAuthorizationStatus.onNext(status)
    }
    
    public func locationManager(_ manager: CLLocationManager,
                                didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        var userLocation = LastLocation(lattitude: location.coordinate.latitude,
                                        longitude: location.coordinate.longitude,
                                        timeStamp: location.timestamp.timeIntervalSince1970)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placeMarks, error in
            guard error == nil, let placeMark = placeMarks?.first else {
                self.subjects.currentLocation.onNext(userLocation)
                return
            }
            userLocation.placeMark = placeMark.name ?? placeMark.subLocality ?? placeMark.locality
            self.subjects.currentLocation.onNext(userLocation)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.subjects.occurError.onNext(error)
    }
}


extension LocationMonitoringServiceImple {
    
    public func fetchLastLocation() -> Maybe<LastLocation> {
        
        let request: () -> Void = { [weak self] in
            self?.locationManager.requestLocation()
        }
        let existingValue = try? self.subjects.currentLocation.value()
        let skipCount = existingValue == nil ? 0 : 1
        return self.subjects.currentLocation
            .compactMap{ $0 }
            .skip(skipCount)
            .first().asObservable()
            .compactMap { $0 }
            .do(onSubscribed: request)
            .asMaybe()
    }
    
    public func startMonitoring(with option: LocationMonitoringOption) {
        self.locationManager.desiredAccuracy = option.accuracy.cLLAccuracy
        self.locationManager.distanceFilter = CLLocationDistance(option.distanceFilter)
        self.locationManager.startUpdatingLocation()
    }
    
    public func stopMonitoring() {
        self.locationManager.stopUpdatingLocation()
    }
    
    public var currentUserLocation: Observable<LastLocation> {
        return self.subjects.currentLocation.compactMap{ $0 }
    }
    
    public var occurError: Observable<Error> {
        return self.subjects.occurError.asObservable()
    }
    
    public var isAuthorized: Observable<Bool> {
        return self.subjects.currentAuthorizationStatus
            .map{ $0 == .authorizedAlways || $0 == .authorizedWhenInUse }
    }
}


private extension LocationMonitoringOption.Accuracy {
    
    var cLLAccuracy: CLLocationAccuracy {
        switch self {
        case .best: return kCLLocationAccuracyBest
        case .tenMeters: return kCLLocationAccuracyNearestTenMeters
        case .hundredMeters: return kCLLocationAccuracyHundredMeters
        case .kiloMeters: return kCLLocationAccuracyKilometer
        case .threeKilometers: return kCLLocationAccuracyThreeKilometers
        }
    }
}
