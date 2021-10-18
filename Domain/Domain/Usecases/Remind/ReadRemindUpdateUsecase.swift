//
//  ReadRemindUpdateUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadRemindUpdateUsecase {
    
    func scheduleRemind(for itemID: String, at futureTime: TimeStamp) -> Maybe<ReadRemind>
    
    func cancelRemin(for uid: String) -> Maybe<Void>
}
