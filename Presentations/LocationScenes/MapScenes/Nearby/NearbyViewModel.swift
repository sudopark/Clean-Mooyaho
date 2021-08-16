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


public struct HoorayMarker {
    
    let isMine: Bool
    let hoorayID: String
    let publisherID: String
    let hoorayKeyword: String
    let timeLabel: String
    let message: String
    let image: ImageSource?
    let spreadDistance: Meters
    let aliveDuration: TimeInterval
    
    var ackCount: Int = 0
    var reactions: [HoorayReaction] = []
}

public protocol NearbyViewModel: AnyObject {

    // interactor
    func preparePermission()
    func userPositionChanged(_ placeMark: String)
    func moveMapCameraToCurrentUserPosition()
    
    // presenter
    var moveCamera: Observable<MapCameramovement> { get }
    var alertUnavailToUseService: Observable<Void> { get }
    var newHooray: Observable<HoorayMarker> { get }
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
    private let hoorayUsecase: HoorayUsecase
    private let router: NearbyRouting
    
    public init(locationUsecase: UserLocationUsecase,
                hoorayUsecase: HoorayUsecase,
                router: NearbyRouting) {
        self.locationUsecase = locationUsecase
        self.hoorayUsecase = hoorayUsecase
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
    
    public var newHooray: Observable<HoorayMarker> {
        
        let publishedHooray = self.hoorayUsecase.newHoorayPublished.map{ $0.asMarker(isMine: true) }
        let receivedHooray = self.hoorayUsecase.receivedNewHooray().map{ $0.asMarker(isMine: false) }
        
        return Observable
            .merge(publishedHooray, receivedHooray)
            .distinctUntilChanged{ $0.hoorayID == $1.hoorayID }
    }
}


private extension LastLocation {
    
    var coordinate: Coordinate {
        return .init(latt: self.lattitude, long: self.longitude)
    }
}

private extension Hooray {
    
    func asMarker(isMine: Bool) -> HoorayMarker {
        let timeAgo = self.timeStamp.timeAgoText
        return HoorayMarker(isMine: isMine,
                            hoorayID: self.uid, publisherID: self.publisherID,
                            hoorayKeyword: self.hoorayKeyword,
                            timeLabel: timeAgo, message: self.message, image: self.image,
                            spreadDistance: self.spreadDistance, aliveDuration: self.aliveDuration)
    }
}

private extension HoorayUsecase {
    
    func receivedNewHooray() -> Observable<Hooray> {
        
        let thenLoadHooray: (NewHoorayMessage) -> Maybe<Hooray> = { [weak self] message in
            return self?.loadHooray(message.hoorayID) ?? .empty()
        }
        
        return self.newReceivedHoorayMessage
            .flatMap(thenLoadHooray)
            .map{ hooray -> Hooray? in hooray }
            .catchAndReturn(nil)
            .compactMap{ $0 }
    }
}
