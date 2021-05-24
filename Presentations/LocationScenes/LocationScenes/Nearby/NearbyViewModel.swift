//
//  NearbyViewModel.swift
//  LocationScenes
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

public enum MapCameraPosition {
    case `default`(_ position: Coordinate)
    case userLocation(_ position: Coordinate)
}

public protocol NearbyViewModel: AnyObject {

    // interactor
    func preparePermission()
    func userPositionChanged(_ placeMark: String)
    
    // presenter
    var cameraPosition: Observable<MapCameraPosition> { get }
    var alertUnavailToUseService: Observable<Void> { get }
}


// MARK: - NearbyViewModelImple

public final class NearbyViewModelImple: NearbyViewModel {
    
    private var defaultLocation: Coordinate {
        return .init(latt: 37.5657332, long: 126.97297)
    }
    
    fileprivate final class Subjects {
        // define subjects
        let moveCameraPosition = PublishSubject<MapCameraPosition>()
        let unavailToUse = PublishSubject<Void>()
        let placeMark = PublishSubject<String>()
    }
    
    private let locationUsecase: UserLocationUsecase
    private let router: NearbyRouting
    private let eventSignal: EventSignal<NearbySceneEvents>
    
    public init(locationUsecase: UserLocationUsecase,
                router: NearbyRouting,
                eventSignal: @escaping EventSignal<NearbySceneEvents>) {
        self.locationUsecase = locationUsecase
        self.router = router
        self.eventSignal = eventSignal
        
        self.internalBind()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBind() {
        
        self.subjects.placeMark.distinctUntilChanged()
            .subscribe(onNext: { [weak self] placeMark in
                self?.eventSignal(.curretPosition(placeMark: placeMark))
            })
            .disposed(by: self.disposeBag)
    }
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
        
        let setupCameraPosition: (Bool) -> Maybe<MapCameraPosition> = { [weak self] grant in
            guard let self = self else { return .empty() }
            return grant ? self.locationUsecase.fetchUserLocation().map{ .userLocation($0.coordinate) }
                : .just(.default(self.defaultLocation))
        }
        
        let handleFetchResult: (MapCameraPosition) -> Void = { [weak self] position in
            
            self?.subjects.moveCameraPosition.onNext(position)
            
            guard case .default = position else { return }
            self?.subjects.unavailToUse.onNext()
            self?.eventSignal(.unavailToUseService)
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
}


// MARK: - NearbyViewModelImple Presenter

extension NearbyViewModelImple {
    
    public var cameraPosition: Observable<MapCameraPosition> {
        return self.subjects.moveCameraPosition.asObservable()
    }
    
    public var alertUnavailToUseService: Observable<Void> {
        return self.subjects.unavailToUse.asObservable()
    }
}


private extension LastLocation {
    
    var coordinate: Coordinate {
        return .init(latt: self.lattitude, long: self.longitude)
    }
}
