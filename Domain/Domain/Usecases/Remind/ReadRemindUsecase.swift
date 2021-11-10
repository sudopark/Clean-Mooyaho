//
//  ReadRemindUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - ReadRemindUsecase

public protocol ReadRemindUsecase {
    
    func preparePermission() -> Maybe<Bool>
    
    func updateRemind(for item: ReadItem, futureTime: TimeStamp?) -> Maybe<Void>
    
    func handleReminder(_ readReminder: ReadRemindMessage) -> Maybe<Void>
}

extension ReadRemindUsecase {
    
    public func scheduleRemid(for item: ReadItem, futureTime: TimeStamp) -> Maybe<Void> {
        return self.updateRemind(for: item, futureTime: futureTime)
    }
    
    public func cancelRemind(for item: ReadItem) -> Maybe<Void> {
        return self.updateRemind(for: item, futureTime: nil)
    }
}
