//
//  LocationSelectViewModel.swift
//  MapScenes
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - LocationSelectViewModel

public protocol LocationSelectViewModel: AnyObject {

    // interactor
    func selectCurrentLocation(_ coordinate: Coordinate)
    func updateAddress(_ address: String)
    func confirmSelect()
    
    // presenter
    var previousSelectedInfo: Location? { get }
    var isConfirmable: Observable<Bool> { get }
    var addrees: Observable<String> { get }
    
    var selectedLocation: Observable<Location> { get }
}


// MARK: - LocationSelectViewModelImple

public final class LocationSelectViewModelImple: LocationSelectViewModel {
    
    private let previousInfo: Location?
    private let throttleInterval: Int
    private let userLocationUsecase: UserLocationUsecase
    private let router: LocationSelectRouting
    
    public init(_ previousInfo: Location?,
                throttleInterval: Int = 700,
                userLocationUsecase: UserLocationUsecase,
                router: LocationSelectRouting) {
        self.previousInfo = previousInfo
        self.throttleInterval = throttleInterval
        self.userLocationUsecase = userLocationUsecase
        self.router = router
        
        self.internalBind()
        
        guard let previous = previousInfo else { return }
        self.subjects.centerCoordinate.onNext(previous.coordinate)
        self.subjects.centerLocation.accept(previous)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let centerCoordinate = BehaviorSubject<Coordinate?>(value: nil)
        let centerLocation = BehaviorRelay<Location?>(value: nil)
        @AutoCompletable var selectedPosition = PublishSubject<Location>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBind() {
        
        let fetchPlaceMark: (Coordinate) -> Observable<Location> = { [weak self] coord in
            guard let self = self else { return .empty() }
            return self.userLocationUsecase.convertToPlaceMark(coord)
                .catch{ _ in .empty() }
                .map{ Location(coordinate: coord, placeMark: $0) }
                .asObservable()
        }
        
        let interval = self.throttleInterval
        self.subjects.centerCoordinate.compactMap{ $0 }
            .throttle(.milliseconds(interval), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .flatMapLatest(fetchPlaceMark)
            .subscribe(onNext: { [weak self] location in
                self?.subjects.centerLocation.accept(location)
            })
            .disposed(by: self.disposeBag)
        
    }
}


// MARK: - LocationSelectViewModelImple Interactor

extension LocationSelectViewModelImple {
    
    public func selectCurrentLocation(_ coordinate: Coordinate) {
        self.subjects.centerCoordinate.onNext(coordinate)
    }
    
    public func updateAddress(_ address: String) {
        guard var location = self.subjects.centerLocation.value else { return }
        location.placeMark = .userDefine(address)
        self.subjects.centerLocation.accept(location)
    }
    
    public func confirmSelect() {
        guard let location = self.subjects.centerLocation.value else { return }
        
        self.router.closeScene(animated: true) { [weak self] in
            self?.subjects.selectedPosition.onNext(location)
        }
    }
}


// MARK: - LocationSelectViewModelImple Presenter

extension LocationSelectViewModelImple {
    
    public var previousSelectedInfo: Location? {
        return self.previousInfo
    }
    
    public var addrees: Observable<String> {
        return self.subjects.centerLocation
            .compactMap{ $0?.placeMark.address }
            .distinctUntilChanged()
    }
    
    public var isConfirmable: Observable<Bool> {
        
        return self.subjects.centerLocation
            .map{ $0?.placeMark.address.isNotEmpty == true }
            .distinctUntilChanged()
    }
    
    public var selectedLocation: Observable<Location> {
        return self.subjects.selectedPosition.compactMap{ $0 }
    }
}
