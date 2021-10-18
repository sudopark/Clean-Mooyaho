//
//  ReadRemindHandlingUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/18.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadRemindHandlingUsecase {
    
    func readRemind(for itemID: String) -> Observable<ReadRemind>
    
    func handleReminder(_ readReminder: ReadRemind) -> Maybe<Void>
}
