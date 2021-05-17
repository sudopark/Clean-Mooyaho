//
//  Expression+Extensions.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


extension Bool {
    
    public func then(_ action: () -> Void) {
        guard self else { return }
        action()
    }
}

extension Optional {
    
    public func whenExists(_ action: (Wrapped) -> Void) {
        guard case let .some(wrapped) = self else { return }
        action(wrapped)
    }
    
    public func whenNotExists(_ action: () -> Void) {
        guard case .none = self else { return }
        action()
    }
    
    public func when(exists: (Wrapped) -> Void, or notExists: () -> Void) {
        switch self {
        case let .some(wrapped): exists(wrapped)
        case .none: notExists()
        }
    }
    
    public func when<V>(exists transform: (Wrapped) -> V,
                        or returnDefault: () -> V) -> V {
        switch self {
        case let .some(wrapped): return transform(wrapped)
        case .none: return returnDefault()
        }
    }
    
    public func escapeWhen<V>(exists transform: @escaping (Wrapped) -> V,
                              or returnDefault: () -> V) -> V {
        switch self {
        case let .some(wrapped): return transform(wrapped)
        case .none: return returnDefault()
        }
    }
}


extension Collection {
    
    public var isNotEmpty: Bool { self.isEmpty == false }
}
