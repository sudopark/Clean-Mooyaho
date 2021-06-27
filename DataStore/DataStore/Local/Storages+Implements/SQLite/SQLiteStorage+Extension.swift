//
//  SQLiteStorage+Extension.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SQLiteStorage

import Domain


extension SQLiteStorage {
    
    public func run<T>(execute: @escaping (DataBase) throws -> T) -> Maybe<T> {
        
        return Maybe.create { [weak self] callback in
            
            guard let self = self else { return Disposables.create() }
            
            self.run(execute: execute) { result in
                result.runMaybeCallback(callback)
            }
            
            return Disposables.create()
        }
    }
    
    public func migrate(upto version: Int32,
                        steps: @escaping (Int32, DataBase) throws -> Void) -> Maybe<Int32> {
        
        return Maybe.create { [weak self] callback in
            
            guard let self = self else { return Disposables.create() }
            
            self.migrate(upto: version, steps: steps) { result in
                result.runMaybeCallback(callback)
            }
            
            return Disposables.create()
        }
    }
}
