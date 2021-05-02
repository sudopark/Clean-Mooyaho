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


class StubLocationService: LocationService, Stubbable {
    
    func checkHasPermission() -> Maybe<LocationServiceAccessPermission> {
        return self.resolve(key: "checkHasPermission") ?? .empty()
    }
    
    func requestPermission() -> Maybe<Bool> {
        return self.resolve(key: "requestPermission") ?? .empty()
    }
    
    func startMonitoring(with option: LocationMonitoringOption) {
        self.verify(key: "startMonitoring", with: option)
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
}
