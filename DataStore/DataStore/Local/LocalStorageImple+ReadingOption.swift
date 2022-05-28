//
//  LocalStorageImple+ReadingOption.swift
//  DataStore
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    public func fetchLastReadPosition(for itemID: String) -> Maybe<Float?> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchLastReadPosition(for: itemID)
    }
    
    public func updateLastReadPosition(for itemID: String, _ position: Float) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.updateLastReadPosition(for: itemID, position)
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) {
        self.environmentStorage.updateEnableLastReadPositionSaveOption(isOn)
    }
    
    public func isEnabledLastReadPositionSaveOption() -> Bool {
        return self.environmentStorage.isEnabledLastReadPositionSaveOption()
    }
}
