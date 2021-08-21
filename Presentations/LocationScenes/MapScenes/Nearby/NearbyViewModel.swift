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
import Overture

import Domain
import CommonPresenting

// MARK: - NearbyViewModel


public struct HoorayMarker {
    
    let isNew: Bool
    var withFocusAnimation: Bool = false
    let hoorayID: String
    let publisherID: String
    let hoorayKeyword: String
    let timeLabel: String
    let removeAt: TimeInterval
    let message: String
    let image: ImageSource?
    let coordinate: Coordinate
    let spreadDistance: Meters
    let aliveDuration: TimeInterval
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
    var recentNearbyHoorays: Observable<[HoorayMarker]> { get }
    func hoorayMarkerImage(_ marker: HoorayMarker) -> Observable<ImageSource>
}


// MARK: - NearbyViewModelImple

public final class NearbyViewModelImple: NearbyViewModel {
    
    private var defaultLocation: Coordinate {
        return .init(latt: 37.5657332, long: 126.97297)
    }
    
    private let locationUsecase: UserLocationUsecase
    private let hoorayUsecase: HoorayUsecase
    private let memberUsecase: MemberUsecase
    private let router: NearbyRouting
    
    public init(locationUsecase: UserLocationUsecase,
                hoorayUsecase: HoorayUsecase,
                memberUsecase: MemberUsecase,
                router: NearbyRouting) {
        self.locationUsecase = locationUsecase
        self.hoorayUsecase = hoorayUsecase
        self.memberUsecase = memberUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    fileprivate final class Subjects {
        // define subjects
        let moveCameraPosition = PublishSubject<MapCameramovement>()
        let recentNearbyHooraysMap = BehaviorSubject<[String: Hooray]>(value: [:])
        @AutoCompletable var unavailToUse = PublishSubject<Void>()
        @AutoCompletable var placeMark = PublishSubject<String>()
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
            self.loadRecentNearbyHooraysIfPossible(coordinate)
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
    
    private func loadRecentNearbyHooraysIfPossible(_ coordinate: Coordinate?) {
        guard let coord = coordinate else { return }
        
        let updateRecentHoorays: ([Hooray]) -> Void = { [weak self] hoorays in
            let map = hoorays.reduce(into: [String: Hooray]()) { $0[$1.uid] = $1 }
            self?.subjects.recentNearbyHooraysMap.onNext(map)
        }
        self.hoorayUsecase.loadNearbyRecentHoorays(at: coord)
            .subscribe(onSuccess: updateRecentHoorays)
            .disposed(by: self.disposeBag)
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
        
        let publishedHooray = self.hoorayUsecase.newHoorayPublished
            .map{ $0.asMarker(isNew: true, withFocus: true) }
        let receivedHooray = self.hoorayUsecase.receivedNewHooray()
            .map{ $0.asMarker(isNew: true, withFocus: false) }
        
        return Observable
            .merge(publishedHooray, receivedHooray)
            .distinctUntilChanged{ $0.hoorayID == $1.hoorayID }
    }
    
    public var recentNearbyHoorays: Observable<[HoorayMarker]> {
        return self.subjects.recentNearbyHooraysMap
            .filter{ $0.isNotEmpty }
            .map{ $0.values }
            .map{ $0.map{ $0.asMarker(isNew: false, withFocus: false) } }
    }
    
    public func hoorayMarkerImage(_ marker: HoorayMarker) -> Observable<ImageSource> {

        let hoorayImage: Observable<ImageSource?> = .just(marker.image)
        
        let orUsePublisherIconIfExists: (ImageSource?) -> Observable<ImageSource?>
        orUsePublisherIconIfExists = { [weak self] hoorayImage in
            guard let self = self else { return .empty() }
            return hoorayImage.map{ .just($0)} ?? self.memberUsecase.memberIcon(marker.publisherID)
        }
        
        let orUseDefaultImageBothNotExist: (ImageSource?) -> ImageSource = { $0 ?? Hooray.defaultMarkerIcon }
        
        return hoorayImage
            .flatMap(orUsePublisherIconIfExists)
            .map(orUseDefaultImageBothNotExist)
    }
}

private extension Hooray {
    
    func asMarker(isNew: Bool, withFocus: Bool) -> HoorayMarker {
        let timeAgo = self.timeStamp.timeAgoText
        let marker = HoorayMarker(isNew: isNew,
                                  hoorayID: self.uid, publisherID: self.publisherID,
                                  hoorayKeyword: self.hoorayKeyword,
                                  timeLabel: timeAgo,
                                  removeAt: self.timeStamp + self.aliveDuration,
                                  message: self.message,
                                  image: self.image,
                                  coordinate: self.location,
                                  spreadDistance: self.spreadDistance,
                                  aliveDuration: self.aliveDuration)
        return update(marker) { $0.withFocusAnimation = withFocus }
    }
    
    static var defaultMarkerIcon: ImageSource {
        return .emoji("🤪")
    }
}

private extension HoorayUsecase {
    
    func receivedNewHooray() -> Observable<Hooray> {
        
        let thenLoadHooray: (NewHoorayMessage) -> Maybe<Hooray> = { [weak self] message in
            return self?.loadHooray(message.hoorayID) ?? .empty()
        }
        
        return self.newReceivedHoorayMessage
            .flatMap(thenLoadHooray)
            .mapAsOptional()
            .catchAndReturn(nil)
            .compactMap{ $0 }
    }
}

private extension MemberUsecase {
    
    func memberIcon(_ uid: String) -> Observable<ImageSource?> {
        return self.members(for: [uid])
            .map{ $0[uid] }
            .map{ $0?.icon }
    }
}
