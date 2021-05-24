//
//  StubUserLocationUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/05/23.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class StubUserLocationUsecase: UserLocationUsecase, Stubbable {
    
    public init() {}
    
    open func checkHasPermission() -> Maybe<LocationServiceAccessPermission> {
        return self.resolve(key: "checkHasPermission") ?? .empty()
    }
    
    open func requestPermission() -> Maybe<Bool> {
        return self.resolve(key: "requestPermission") ?? .empty()
    }

    open func fetchUserLocation() -> Maybe<LastLocation> {
        return self.resolve(key: "fetchUserLocation") ?? .empty()
    }
    
    open func startUploadUserLocation(for memberID: String) {
        self.verify(key: "startUploadUserLocation")
    }
    
    open func stopUplocationUserLocation() {
        self.verify(key: "stopUplocationUserLocation")
    }

    public let stubMonitoringError = PublishSubject<Error>()
    open var monitoringError: Observable<Error> {
        return stubMonitoringError.asObservable()
    }
    
    public let stubIsAuthorized = PublishSubject<Bool>()
    open var isAuthorized: Observable<Bool> {
        return self.stubIsAuthorized.asObservable()
    }
}
