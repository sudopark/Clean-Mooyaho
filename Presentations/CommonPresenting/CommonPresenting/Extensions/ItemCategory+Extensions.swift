//
//  ItemCategory+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/16.
//

import Foundation

import Domain

extension ItemCategory {
    
    public func presentingHashValue() -> Int {
        var hasher = Hasher()
        hasher.combine(self.uid)
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}
