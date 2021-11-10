//
//  RemindOptionUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/11/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol RemindOptionUsecase {
    
    func loadDefaultRemindTime() -> Maybe<RemindTime>
    
    func updateDefaultRemindTime(_ time: RemindTime) -> Maybe<Void>
}
