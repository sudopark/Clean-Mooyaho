//
//  Stubs.swift
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

public protocol Containable: class { }

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
}


// MARK: - Stub

public protocol Stubbable: Containable { }

// MARK: Stub for register

extension Stubbable {
    
    public func register<R>(key: String, resultProvider: @escaping () -> R) {
        self.put(key: key.withStubPrefix, value: resultProvider)
    }
}

// MARK: Stub for resolve

extension Stubbable {
    
    public func resolve<R>(key: String) -> R? {
        guard let provider = self.get(key: key.withStubPrefix, mapping: { $0 as? () -> R }) else {
            return nil
        }
        
        return provider()
    }
    
    public func resolve<R>(key: String, defaultResult: R) -> R {
        return self.resolve(key: key.withStubPrefix) ?? defaultResult
    }
}

// MARK: - Stub for register and invoke verify

extension Stubbable {
    
    public func verify(key: String, with args: Any? = nil) {
        typealias Verifier = (Any?) -> Void
        let verifier = self.get(key: key.withSpyPrefix, mapping: { $0 as? Verifier })
        verifier?(args)
    }
    
    public func called(key: String, callback: @escaping (Any?) -> Void) {
        self.put(key: key.withSpyPrefix, value: callback)
    }
}


// MARK: - Helper Extensions

private extension String {
    
    var withStubPrefix: String {
        return "stub_\(self)"
    }
    
    var withSpyPrefix: String {
        return "spy_\(self)"
    }
}


private extension Optional {
    
    var descriptionForKey: String? {
        return self.map { wrapped in
            return "\(wrapped)"
        }
    }
}


private func functionAddress<A, R>(of f: @escaping (A) throws -> R) -> Int {
  let (_, lo) = unsafeBitCast(f, to: (Int, Int).self)
  let offset = MemoryLayout<Int>.size == 8 ? 16 : 12
  let pointer = UnsafePointer<Int>(bitPattern: lo + offset)!
  return pointer.pointee
}
