//
//  RepositoryImple+ReadingOptions.swift
//  DataStore
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadingOptionsRepositoryDefImpleDependency: AnyObject {
    
    var readingOptionLocal: ReadingOptionLocalStorage { get }
}


extension ReadingOptionRepository where Self: ReadingOptionsRepositoryDefImpleDependency {
    
    public func fetchLastReadPosition(for itemID: String) -> Maybe<Float?> {
        return self.readingOptionLocal.fetchLastReadPosition(for: itemID)
    }
    
    public func updateLastReadPosition(for itemID: String, _ position: Float) -> Maybe<Void> {
        return self.readingOptionLocal.updateLastReadPosition(for: itemID, position)
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) {
        self.readingOptionLocal.updateEnableLastReadPositionSaveOption(isOn)
    }
    
    public func isEnabledLastReadPositionSaveOption() -> Bool {
        return self.readingOptionLocal.isEnabledLastReadPositionSaveOption()
    }
}

