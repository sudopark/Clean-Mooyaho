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
        return self.resolve(key: "checkHasPermission") ?? .empty()
    }
    
    open func startUploadUserLocation(with option: LocationMonitoringOption, for member: Member) {
        self.verify(key: "startUploadUserLocation")
    }
    
    open func stopUplocationUserLocation() {
        self.verify(key: "stopUplocationUserLocation")
    }

    public let stubMonitoringError = PublishSubject<Error>()
    open var monitoringError: Observable<Error> {
        return stubMonitoringError.asObservable()
    }
}
