//
//  ReadRemindUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Extensions


// MARK: - ReadRemindUsecase

public protocol ReadRemindUsecase: Sendable {
    
    func preparePermission() -> Maybe<Bool>
    
    func updateRemind(for item: ReadItem, futureTime: TimeStamp?) -> Maybe<Void>
    
    func scheduleRemindMessage(for item: ReadItem, at futureTime: TimeStamp) -> Maybe<Void>
    
    func cancelRemindMessage(_ item: ReadItem) -> Maybe<Void>
    
    func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void>
}
