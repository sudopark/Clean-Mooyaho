//
//  ReadItemOptionsUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadItemOptionsUsecase {
    
    func loadShrinkModeIsOnOption() -> Maybe<Bool>
    
    func updateIsShrinkModeIsOn(_ newvalue: Bool) -> Maybe<Void>
}
