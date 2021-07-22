//
//  MockLocationMonitoringService.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class MockLocationMonitoringService: LocationMonitoringService, Mocking {
    
    func fetchLastLocation() -> Maybe<LastLocation> {
        return self.resolve(key: "fetchLastLocation") ?? .empty()
    }
    
    func checkHasPermission() -> Maybe<LocationServiceAccessPermission> {
        return self.resolve(key: "checkHasPermission") ?? .empty()
    }
    
    func requestPermission() -> Maybe<Bool> {
        return self.resolve(key: "requestPermission") ?? .empty()
    }
    
    func startMonitoring(with option: LocationMonitoringOption) {
        self.verify(key: "startMonitoring", with: option)
        if let stubLocation: LastLocation = self.resolve(key: "startMonitoring:result") {
            self.locationSubject.onNext(stubLocation)
        }
    }
    
    func stopMonitoring() {
        self.verify(key: "stopMonitoring")
    }
    
    let locationSubject = PublishSubject<LastLocation>()
    var currentUserLocation: Observable<LastLocation> {
        return self.locationSubject.asObservable()
    }
    
    var occurError: Observable<Error> {
        return .empty()
    }
    
    let autorized = PublishSubject<Bool>()
    var isAuthorized: Observable<Bool> {
        return autorized.asObservable()
    }
}
