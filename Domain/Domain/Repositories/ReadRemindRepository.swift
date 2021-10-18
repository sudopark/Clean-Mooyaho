//
//  ReadRemindRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadRemindRepository {
    
    func requestLoadReadReminds(for itemID: String) -> Observable<ReadRemind>
    
    func requestScheduleReadRemind(_ readRemind: ReadRemind) -> Maybe<Void>
    
    func requestCancelReadRemind(for uid: String) -> Maybe<Void>
}
