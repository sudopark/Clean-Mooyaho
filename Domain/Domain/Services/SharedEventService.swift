//
//  SharedEventService.swift
//  Domain
//
//  Created by sudo.park on 2021/12/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - SharedEventService

public protocol SharedEvent { }

public protocol SharedEventService {

    func notify(event: SharedEvent)
    
    var event: Observable<SharedEvent> { get }
}


// MARK: - SharedEventServiceImple

public final class SharedEventServiceImple: SharedEventService {

    private let eventSubject = PublishSubject<SharedEvent>()
    
    public init() { }
}

extension SharedEventServiceImple {
    
    public func notify(event: SharedEvent) {
        self.eventSubject.onNext(event)
    }
    
    public var event: Observable<SharedEvent> {
        return self.eventSubject
            .asObservable()
    }
}
