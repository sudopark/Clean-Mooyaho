//
//  ReadItemSyncUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/12/17.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol ReadItemSyncUsecase: AnyObject {
    
    var reloadNeedCollectionIDs: [String] { get set }
}


extension ReadItemUsecaseImple: ReadItemSyncUsecase {
    
    public var reloadNeedCollectionIDs: [String] {
        get {
            return self.itemsRespoitory.reloadNeedCollectionIDs()
        } set {
            self.itemsRespoitory.updateIsReloadNeedCollectionIDs(newValue)
        }
    }
}
