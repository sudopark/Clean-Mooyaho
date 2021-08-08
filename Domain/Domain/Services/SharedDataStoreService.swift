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

public protocol SharedDataStoreService: AuthInfoProvider {
    
    func update<V>(_ key: String, mutating: (V?) -> V?)
    
    func get<V>(_ key: String) -> V?
    
    func delete(_ key: String)
    
    func observe<V>(_ key: String) -> Observable<V>
    
    func observeWithCache<V>(_ key: String) -> Observable<V>
    
    func flush()
}

extension SharedDataStoreService {
    
    func update<V>(_ key: String, value: V) {
        self.update(key, mutating: { _ in value })
    }
}


// MARK: - SharedDataStoreServiceImple

public final class SharedDataStoreServiceImple: SharedDataStoreService {
    
    private let updatedKey = BehaviorSubject<String?>(value: nil)
    private let internalStore: BehaviorRelay<[String: Any]> = .init(value: [:])
    private let lock: NSRecursiveLock = .init()
    
    private let observingScheduler: SchedulerType
    
    public init(observingScheduler: SchedulerType = MainScheduler.instance) {
        self.observingScheduler = observingScheduler
    }
}

extension SharedDataStoreServiceImple {
    
    public func update<V>(_ key: String, mutating: (V?) -> V?) {
        self.lock.lock(); defer { self.lock.unlock() }
        var dict = self.internalStore.value
        let stored = dict[key] as? V
        let newvalue = mutating(stored)
        dict[key] = newvalue
        self.internalStore.accept(dict)
        self.updatedKey.onNext(key)
    }
    
    public func get<V>(_ key: String) -> V? {
        return self.internalStore.value[key] as? V
    }
    
    public func delete(_ key: String) {
        self.lock.lock(); defer { self.lock.unlock() }
        var dict = self.internalStore.value
        dict[key] = nil
        self.internalStore.accept(dict)
        self.updatedKey.onNext(key)
    }
    
    public func observe<V>(_ key: String) -> Observable<V> {
        
        let dataChanges: (String?, [String: Any]) -> V? = { key, dict in
            guard let key = key else { return nil }
            return dict[key] as? V
            
        }
        return self.updatedKey
            .filter{ $0 == key }
            .withLatestFrom(self.internalStore, resultSelector: dataChanges)
            .compactMap { $0 }
            .observe(on: self.observingScheduler)
    }
    
    public func observeWithCache<V>(_ key: String) -> Observable<V> {
        let cached: V? = self.get(key)
        let updates: Observable<V?> = self.observe(key).map{ v -> V? in v }
        return updates
            .startWith(cached)
            .compactMap{ $0 }
    }
    
    public func flush() {
        self.lock.lock(); defer { self.lock.unlock() }
        self.internalStore.accept([:])
        self.updatedKey.onNext(nil)
    }
}


// MARK: - manage auth

extension SharedDataStoreServiceImple: AuthInfoManger {
    
    public func currentAuth() -> Auth? {
        return self.get(SharedDataKeys.auth.rawValue)
    }
    
    public func updateAuth(_ newValue: Auth) {
        self.update(SharedDataKeys.auth.rawValue, value: newValue)
    }
    
    public func clearAuth() {
        self.delete(SharedDataKeys.auth.rawValue)
    }
}
