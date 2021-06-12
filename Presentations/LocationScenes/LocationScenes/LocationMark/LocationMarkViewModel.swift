//
//  LocationMarkViewModel.swift
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


// MARK: - LocationMarkViewModel

public protocol LocationMarkViewModel: AnyObject {

    // interactor
    func updatePlaceMark(at coordinate: Coordinate)
    
    // presenter
    var markerPosition: Observable<Coordinate> { get }
}


// MARK: - LocationMarkViewModelImple

public final class LocationMarkViewModelImple: LocationMarkViewModel {
    
    private let router: LocationMarkRouting
    
    public init(router: LocationMarkRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let position = BehaviorSubject<Coordinate?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - LocationMarkViewModelImple Interactor

extension LocationMarkViewModelImple {
    
    public func updatePlaceMark(at coordinate: Coordinate) {
        self.subjects.position.onNext(coordinate)
    }
}


// MARK: - LocationMarkViewModelImple Presenter

extension LocationMarkViewModelImple {
    
    public var markerPosition: Observable<Coordinate> {
        return self.subjects.position.compactMap{ $0 }
    }
}
