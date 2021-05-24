//
//  StubLocationService.swift
//  DomainTests
//
//  Created by ParkHyunsoo on 2021/05/03.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import UnitTestHelpKit

@testable import Domain


class StubLocationMonitoringService: LocationMonitoringService, Stubbable {
    
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
            self.stubLocationSubject.onNext(stubLocation)
        }
    }
    
    func stopMonitoring() {
        self.verify(key: "stopMonitoring")
    }
    
    let stubLocationSubject = PublishSubject<LastLocation>()
    var currentUserLocation: Observable<LastLocation> {
        return self.stubLocationSubject.asObservable()
    }
    
    var occurError: Observable<Error> {
        return .empty()
    }
    
    let stubAutorized = PublishSubject<Bool>()
    var isAuthorized: Observable<Bool> {
        return stubAutorized.asObservable()
    }
}
