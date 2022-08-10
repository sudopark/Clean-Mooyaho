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
import Prelude
import Optics


// MARK: - SharedDataStoreService

public protocol SharedDataStoreService: AuthInfoProvider {
    
    func update<V>(_ type: V.Type, key: String, mutating: (V?) -> V?)
    
    func get<V>(_ type: V.Type, key: String) -> V?
    
    func delete(_ key: String)
    
    func observe<V>(_ type: V.Type, key: String) -> Observable<V?>
    
    func observeWithCache<V>(_ type: V.Type, key: String) -> Observable<V?>
    
    func flush()
    
    var isEmpty: Bool { get }
}

extension SharedDataStoreService {
    
    func update<V>(_ type: V.Type, key: String, value: V) {
        self.update(type, key: key, mutating: { _ in value })
    }
    
    public func observeValuesInMappWithSetup<V>(ids: [String],
                                                sharedKey: String,
                                                disposeBag: DisposeBag,
                                                idSelector: @escaping (V) -> String,
                                                localFetchinig: @escaping ([String]) -> Maybe<[V]>,
                                                remoteLoading: @escaping ([String]) -> Maybe<[V]>) -> Observable<[V]> {
        
        let filtering: ([String: V]?) -> [V]? = { dict in
            guard let dict = dict else { return nil }
            return ids.compactMap { dict[$0] }
        }
        let prepare: () -> Void = { [weak self] in
            self?.prepareObserveValues(ids, sharedKey: sharedKey, disposeBag: disposeBag,
                                       idSelector: idSelector,
                                       localFetchinig: localFetchinig, remoteLoading: remoteLoading)
        }
        
        return self.observeWithCache([String: V].self, key: sharedKey)
            .compactMap(filtering)
            .do(onSubscribed: prepare)
    }
    
    private func prepareObserveValues<V>(_ ids: [String],
                                         sharedKey: String,
                                         disposeBag: DisposeBag,
                                         idSelector: @escaping (V) -> String,
                                         localFetchinig: @escaping ([String]) -> Maybe<[V]>,
                                         remoteLoading: @escaping ([String]) -> Maybe<[V]>) {
        let valuesInMemory = self.get([String: V].self, key: sharedKey) ?? [:]
        
        let notExistingIDsInMemory = ids.filter { valuesInMemory[$0] == nil }
        let fetchValuesInLocal = localFetchinig(notExistingIDsInMemory)
        
        let thenLoadValuesFromRemoteIfNeed: ([V]) -> Maybe<[V]> = { localValues in
            let localValueIDSet = Set(localValues.map { idSelector($0) })
            let requireIDs = ids.filter {
                valuesInMemory[$0] == nil && localValueIDSet.contains($0) == false
            }
            return requireIDs.isEmpty
                ? .just(localValues)
                : remoteLoading(requireIDs).map { $0 + localValues }
        }
        
        let updateStore: ([V]) -> Void = { [weak self] newValues in
            guard let self = self else { return }
            self.update([String: V].self, key: sharedKey) {
                return newValues.reduce($0 ?? [:]) { $0 |> key(idSelector($1)) .~ $1 }
            }
        }
        
        fetchValuesInLocal
            .flatMap(thenLoadValuesFromRemoteIfNeed)
            .subscribe(onSuccess: updateStore)
            .disposed(by: disposeBag)
    }
}


// MARK: - SharedDataStoreServiceImple

public class SharedDataStoreServiceImple: SharedDataStoreService, @unchecked Sendable {
    
    private let updatedKey = BehaviorSubject<String?>(value: nil)
    private let internalStore: BehaviorRelay<[String: Any]> = .init(value: [:])
    private let lock: NSRecursiveLock = .init()
    
    private let observingScheduler: SchedulerType
    
    public init(observingScheduler: SchedulerType = MainScheduler.instance) {
        self.observingScheduler = observingScheduler
    }
}

extension SharedDataStoreServiceImple {
    
    public func update<V>(_ type: V.Type, key: String, mutating: (V?) -> V?) {
        self.lock.lock(); defer { self.lock.unlock() }
        var dict = self.internalStore.value
        let stored = dict[key] as? V
        let newvalue = mutating(stored)
        dict[key] = newvalue
        self.internalStore.accept(dict)
        self.updatedKey.onNext(key)
    }
    
    public func get<V>(_ type: V.Type, key: String) -> V? {
        return self.internalStore.value[key] as? V
    }
    
    public func delete(_ key: String) {
        self.lock.lock(); defer { self.lock.unlock() }
        var dict = self.internalStore.value
        dict[key] = nil
        self.internalStore.accept(dict)
        self.updatedKey.onNext(key)
    }
    
    public func observe<V>(_ type: V.Type, key: String) -> Observable<V?> {
        
        let dataChanges: (String?, [String: Any]) -> V? = { key, dict in
            guard let key = key else { return nil }
            return dict[key] as? V
            
        }
        return self.updatedKey
            .filter{ $0 == key }
            .withLatestFrom(self.internalStore, resultSelector: dataChanges)
            .observe(on: self.observingScheduler)
    }
    
    public func observeWithCache<V>(_ type: V.Type, key: String) -> Observable<V?> {
        let cached: V? = self.get(type, key: key)
        let isLastUpdated = try? self.updatedKey.value() == key
        let updates: Observable<V?> = self.observe(type, key: key).map{ v -> V? in v }
        guard let cache = cached, isLastUpdated == false else {
            return updates
        }
        return updates.startWith(cache)
    }
    
    public func flush() {
        self.lock.lock(); defer { self.lock.unlock() }
        let keys = self.internalStore.value.keys
        self.internalStore.accept([:])
        keys.forEach {
            self.updatedKey.onNext($0)
        }
        self.updatedKey.onNext(nil)
    }
    
    public var isEmpty: Bool {
        return self.internalStore.value.isEmpty
    }
}


// MARK: - manage auth

extension SharedDataStoreServiceImple: AuthInfoManger {
    
    public func currentAuth() -> Auth? {
        return self.get(Auth.self, key: SharedDataKeys.auth.rawValue)
    }
    
    public func signedInMemberID() -> String? {
        return self.get(Member.self, key: SharedDataKeys.currentMember.rawValue)?.uid
    }
    
    public func updateAuth(_ newValue: Auth) {
        self.update(Auth.self, key: SharedDataKeys.auth.rawValue, value: newValue)
    }
    
    public func clearAuth() {
        self.delete(SharedDataKeys.auth.rawValue)
    }
    
    public func updateCurrentMember(_ member: Member) {
        self.save(Member.self, key: .currentMember, member)
    }
}
