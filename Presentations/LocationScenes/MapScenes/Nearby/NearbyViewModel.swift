//
//  NearbyViewModel.swift
//  MapScenes
//
//  Created sudo.park on 2021/05/22.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - NearbyViewModel

public protocol NearbyViewModel: AnyObject {

    // interactor
    func preparePermission()
    func userPositionChanged(_ placeMark: String)
    func moveMapCameraToCurrentUserPosition()
    
    // presenter
    var moveCamera: Observable<MapCameramovement> { get }
    var alertUnavailToUseService: Observable<Void> { get }
}


// MARK: - NearbyViewModelImple

public final class NearbyViewModelImple: NearbyViewModel {
    
    private var defaultLocation: Coordinate {
        return .init(latt: 37.5657332, long: 126.97297)
    }
    
    fileprivate final class Subjects {
        // define subjects
        let moveCameraPosition = PublishSubject<MapCameramovement>()
        @AutoCompletable var unavailToUse = PublishSubject<Void>()
        @AutoCompletable var placeMark = PublishSubject<String>()
    }
    
    private let locationUsecase: UserLocationUsecase
    private let router: NearbyRouting
    
    public init(locationUsecase: UserLocationUsecase,
                router: NearbyRouting) {
        self.locationUsecase = locationUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - NearbyViewModelImple Interactor

extension NearbyViewModelImple {
    
    public func preparePermission() {
        
        let preparePermission: (LocationServiceAccessPermission) -> Maybe<Bool>
        preparePermission = { [weak self] status in
            guard let self = self else { return .empty() }
            switch status {
            case .granted: return .just(true)
            case .notDetermined: return self.locationUsecase.requestPermission()
            default: return .just(false)
            }
        }
        
        let setupCameraPosition: (Bool) -> Maybe<Coordinate?> = { [weak self] grant in
            guard let self = self else { return .empty() }
            return grant ? self.locationUsecase.fetchUserLocation().map{ $0.coordinate }
                : .just(nil)
        }
        
        let handleFetchResult: (Coordinate?) -> Void = { [weak self] coordinate in
            guard let self = self else { return }
            let isGrantDenied = coordinate == nil
            
            let center = coordinate ?? self.defaultLocation
            let movement = MapCameramovement(center: .coordinate(center), withAnimation: false)
            
            self.subjects.moveCameraPosition.onNext(movement)
            
            isGrantDenied.then {
                self.subjects.unavailToUse.onNext()
            }
        }
        
        self.locationUsecase.checkHasPermission()
            .flatMap(preparePermission)
            .flatMap(setupCameraPosition)
            .subscribe(onSuccess: handleFetchResult)
            .disposed(by: self.disposeBag)
    }
    
    public func userPositionChanged(_ placeMark: String) {
        self.subjects.placeMark.onNext(placeMark)
    }
    
    public func moveMapCameraToCurrentUserPosition() {
        let movement = MapCameramovement(center: .currentUserPosition)
        self.subjects.moveCameraPosition.onNext(movement)
    }
}


// MARK: - NearbyViewModelImple Presenter

extension NearbyViewModelImple {
    
    public var moveCamera: Observable<MapCameramovement> {
        return self.subjects.moveCameraPosition.asObservable()
    }
    
    public var alertUnavailToUseService: Observable<Void> {
        return self.subjects.unavailToUse.asObservable()
    }
    
    public var currentPositionPlaceMark: Observable<String> {
        return self.subjects.placeMark.distinctUntilChanged()
    }
}


private extension LastLocation {
    
    var coordinate: Coordinate {
        return .init(latt: self.lattitude, long: self.longitude)
    }
}
