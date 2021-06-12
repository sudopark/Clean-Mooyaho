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
    
    // presenter
    var selectedLocation: Observable<CurrentPosition> { get }
}


// MARK: - LocationSelectViewModelImple

public final class LocationSelectViewModelImple: LocationSelectViewModel {
    
    private let router: LocationSelectRouting
    
    public init(router: LocationSelectRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let selectedPosition = PublishSubject<CurrentPosition>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - LocationSelectViewModelImple Interactor

extension LocationSelectViewModelImple {
    
    public func selectCurrentLocation(_ position: CurrentPosition) {
        
        let emitEvent: () -> Void = { [weak self] in
            self?.subjects.selectedPosition.onNext(position)
        }
        
        self.router.closeScene(animated: true, completed: emitEvent)
    }
}


// MARK: - LocationSelectViewModelImple Presenter

extension LocationSelectViewModelImple {
    
    public var selectedLocation: Observable<CurrentPosition> {
        return self.subjects.selectedPosition.asObservable()
    }
}
