//
//  ReadItemSyncUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/12/17.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol ReadItemSyncUsecase: AnyObject {
    
    var isReloadNeed: Bool { get set }
}


extension ReadItemUsecaseImple: ReadItemSyncUsecase {
    
    public var isReloadNeed: Bool {
        get {
            return self.itemsRespoitory.isReloadNeed()
        } set {
            self.itemsRespoitory.updateIsReloadNeed(newValue)
        }
    }
}
