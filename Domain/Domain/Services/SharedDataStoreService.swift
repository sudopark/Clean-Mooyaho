//
//  SharedDataStoreService.swift
//  Domain
//
//  Created by sudo.park on 2021/05/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


// MARK: - SharedDataStoreService

public protocol SharedDataStoreService {
    
    func save<V>(_ key: String, value: V)
    
    func fetch<V>(_ key: String) -> V?
    
    func delete(_ key: String)
    
    func observe<V>(_ key: String) -> Observable<V>
    
    func flush()
}


// MARK: - SharedDataStoreServiceImple

public final class SharedDataStoreServiceImple: SharedDataStoreService {
    
    private let internalStore: BehaviorRelay<[String: Any]> = .init(value: [:])
    private let lock: NSRecursiveLock = .init()
    
    public init() { }
}

extension SharedDataStoreServiceImple {
    
    public func save<V>(_ key: String, value: V) {
        self.lock.lock(); defer { self.lock.unlock() }
        let newDict = self.internalStore.value.merging([key: value], uniquingKeysWith: { $1 })
        self.internalStore.accept(newDict)
    }
    
    public func fetch<V>(_ key: String) -> V? {
        self.lock.lock(); defer { self.lock.unlock() }
        return self.internalStore.value[key] as? V
    }
    
    public func delete(_ key: String) {
        self.lock.lock(); defer { self.lock.unlock() }
        var dict = self.internalStore.value
        dict[key] = nil
        self.internalStore.accept(dict)
    }
    
    public func observe<V>(_ key: String) -> Observable<V> {
        
        let transform: ([String: Any]) -> V? = { dict in
            return dict[key] as? V
        }
        return self.internalStore.compactMap(transform)
    }
    
    public func flush() {
        self.lock.lock(); defer { self.lock.unlock() }
        self.internalStore.accept([:])
    }
}
