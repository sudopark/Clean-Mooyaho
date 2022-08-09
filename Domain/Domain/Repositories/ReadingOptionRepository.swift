//
//  ReadingOptionRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadingOptionRepository: Sendable, AnyObject {
    
    func fetchLastReadPosition(for itemID: String) -> Maybe<ReadPosition?>
    
    func updateLastReadPosition(for itemID: String, _ position: Double) -> Maybe<ReadPosition>
    
    func updateEnableLastReadPositionSaveOption(_ isOn: Bool)
    
    func isEnabledLastReadPositionSaveOption() -> Bool
}
