//
//  ReadingOptionRepository.swift
//  Domain
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadingOptionRepository: AnyObject {
    
    func fetchLastReadPosition(for itemID: String) -> Maybe<Float?>
    
    func updateLastReadPosition(for itemID: String, _ position: Float) -> Maybe<Void>
    
    func updateEnableLastReadPositionSaveOption(_ isOn: Bool)
    
    func isEnabledLastReadPositionSaveOption() -> Bool
}
