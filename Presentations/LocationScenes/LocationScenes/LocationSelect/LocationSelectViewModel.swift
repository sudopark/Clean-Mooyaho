//
//  LocationSelectViewModel.swift
//  LocationScenes
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
    func selectCurrentLocation(_ position: CurrentPosition)
    func updateAddress(_ text: String)
    func confirmSelect()
    
    // presenter
    var previousSelectedInfo: PreviousSelectedLocationInfo? { get }
    var isConfirmable: Observable<Bool> { get }
    var selectedLocation: Observable<CurrentPosition> { get }
}


// MARK: - LocationSelectViewModelImple

public final class LocationSelectViewModelImple: LocationSelectViewModel {
    
    private let previousInfo: PreviousSelectedLocationInfo?
    private let router: LocationSelectRouting
    
    public init(_ previousInfo: PreviousSelectedLocationInfo?,
                router: LocationSelectRouting) {
        self.previousInfo = previousInfo
        self.router = router
        
        guard let previous = previousInfo else { return }
        self.subjects.position.accept((previous.latt, previous.long))
        self.subjects.address.accept(previous.address)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let position = BehaviorRelay<(Double, Double)?>(value: nil)
        let address = BehaviorRelay<String?>(value: nil)
        let selectedPosition = PublishSubject<CurrentPosition>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - LocationSelectViewModelImple Interactor

extension LocationSelectViewModelImple {
    
    public func selectCurrentLocation(_ position: CurrentPosition) {
        
        let pair = (position.lattitude, position.longitude)
        let address = position.placeMark?.address
        self.subjects.position.accept(pair)
        self.subjects.address.accept(address)
    }
    
    public func updateAddress(_ text: String) {
        
        self.subjects.address.accept(text)
    }
    
    public func confirmSelect() {
        guard let position = self.subjects.position.value,
              let address = self.subjects.address.value, address.isNotEmpty else { return }
        var currentPosition = CurrentPosition(lattitude: position.0, longitude: position.1, timeStamp: .now())
        currentPosition.placeMark = .init(address: address)
        self.router.closeScene(animated: true) { [weak self] in
            self?.subjects.selectedPosition.onNext(currentPosition)
        }
    }
}


// MARK: - LocationSelectViewModelImple Presenter

extension LocationSelectViewModelImple {
    
    public var previousSelectedInfo: PreviousSelectedLocationInfo? {
        return self.previousInfo
    }
    
    public var isConfirmable: Observable<Bool> {
        
        let checkSelectedPlaceInfo: ((Double, Double)?, String?) -> Bool = { pair, address in
            return pair != nil && address?.isNotEmpty == true
        }
        
        return Observable.combineLatest(self.subjects.position,
                                        self.subjects.address,
                                        resultSelector: checkSelectedPlaceInfo)
            .distinctUntilChanged()
    }
    
    public var selectedLocation: Observable<CurrentPosition> {
        return self.subjects.selectedPosition.compactMap{ $0 }
    }
}
