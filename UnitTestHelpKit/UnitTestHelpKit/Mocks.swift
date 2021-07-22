//
//  Mocks.swift
//  UnitTestHelpKit
//
//  Created by ParkHyunsoo on 2021/04/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - Container and Containable

private class Container {
    
    var storage: [String: Any] = [:]
}

private var baseContainerKey: String = "base_container"

// MARK: - Containable

public protocol Containable: AnyObject { }

extension Containable {
    
    private var container: Container {
        if let value = objc_getAssociatedObject(self, &baseContainerKey) as? Container {
            return value
        }
        let container = Container()
        objc_setAssociatedObject(self,
                                 &baseContainerKey,
                                 container,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return container
    }
    
    fileprivate func put(key: String, value: Any) {
        self.container.storage[key] = value
    }
    
    fileprivate func get<V>(key: String, mapping: (Any) -> V?) -> V? {
        guard let anyValue = self.container.storage[key] else {
            return nil
        }
        return mapping(anyValue)
    }
    
    fileprivate func clearContainer(for key: String) {
        self.container.storage[key] = nil
    }
}


// MARK: - Mocking

public protocol Mocking: Containable { }

// MARK: Stub for register

extension Mocking {
    
    public func register<R>(key: String, resultProvider: @escaping () -> R) {
        self.put(key: key.withResultPrefix, value: resultProvider)
    }
    
    public func register<R>(type: R.Type, key: String, resultProvider: @escaping () -> R) {
        self.put(key: key.withResultPrefix, value: resultProvider)
    }
}

// MARK: Stub for resolve

extension Mocking {
    
    public func resolve<R>(key: String) -> R? {
        guard let provider = self.get(key: key.withResultPrefix, mapping: { $0 as? () -> R }) else {
            return nil
        }
        
        return provider()
    }
    
    public func resolve<R>(_ type: R.Type, key: String) -> R? {
        guard let provider = self.get(key: key.withResultPrefix, mapping: { $0 as? () -> R }) else {
            return nil
        }
        return provider()
    }
    
    public func resolve<R>(key: String, defaultResult: R) -> R {
        guard let provider = self.get(key: key.withResultPrefix, mapping: { $0 as? () -> R }) else {
            return defaultResult
        }
        return provider()
    }
}

extension Mocking {
    
    public func clear(key: String) {
        self.clearContainer(for: key.withResultPrefix)
        self.clearContainer(for: key.withCalledPrefix)
    }
}

// MARK: - Stub for register and invoke verify

extension Mocking {
    
    public func verify(key: String, with args: Any? = nil) {
        typealias Verifier = (Any?) -> Void
        let verifier = self.get(key: key.withCalledPrefix, mapping: { $0 as? Verifier })
        verifier?(args)
    }
    
    public func called(key: String, callback: @escaping (Any?) -> Void) {
        self.put(key: key.withCalledPrefix, value: callback)
    }
}


// MARK: - Helper Extensions

private extension String {
    
    var withResultPrefix: String {
        return "result_\(self)"
    }
    
    var withCalledPrefix: String {
        return "call_\(self)"
    }
}
