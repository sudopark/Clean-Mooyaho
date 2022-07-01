//
//  Builder.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


@dynamicMemberLookup
public struct Builder<Base: AnyObject> {
    
    private let accumulatingBuild: () -> Base
    
    public init(_ build: @escaping () -> Base) {
        self.accumulatingBuild = build
    }
    
    public init(base: Base) {
        self.accumulatingBuild = { base }
    }
    
    public subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<Base, Value>) -> (Value) -> Self {
        return { value in
            return Builder {
                let newBase = self.accumulatingBuild()
                newBase[keyPath: keyPath] = value
                return newBase
            }
        }
    }
    
    public func build(with assert: (Base) -> Bool) -> Base? {
        let sender = self.accumulatingBuild()
        guard assert(sender) else { return nil }
        return sender
    }
}
