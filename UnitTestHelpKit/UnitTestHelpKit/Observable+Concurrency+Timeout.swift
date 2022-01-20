//
//  Observable+Concurrency+Timeout.swift
//  UnitTestHelpKit
//
//  Created by sudo.park on 2022/01/21.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


@available(iOS 13.0, *)
public extension ObservableType {
    
    func values(
        with timeoutMillis: TimeInterval,
        scheduler: SchedulerType = MainScheduler.instance
    ) -> AsyncThrowingStream<Element, Error> {
        
        let timeout: RxTimeInterval = .milliseconds(Int(timeoutMillis * 1000))
        return self.timeout(timeout, scheduler: scheduler)
            .values
    }
}
