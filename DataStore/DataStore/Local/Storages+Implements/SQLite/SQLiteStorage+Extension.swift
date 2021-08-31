//
//  SQLiteStorage+Extension.swift
//  DataStore
//
//  Created by sudo.park on 2021/06/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SQLiteService

import Domain


extension SQLiteService: ReactiveCompatible { }


extension Reactive where Base == SQLiteService {
    
    public func run<T>(execute: @escaping (DataBase) throws -> T) -> Maybe<T> {
        
        return Maybe.create { [weak base] callback in
            
            guard let base = base else { return Disposables.create() }
            
            base.run(execute: execute) { result in
                result.runMaybeCallback(callback)
            }
            
            return Disposables.create()
        }
    }
    
    public func migrate(upto version: Int32,
                        steps: @escaping (Int32, DataBase) throws -> Void,
                        finalized: @escaping (Int32, DataBase) -> Void) -> Maybe<Int32> {
        
        return Maybe.create { [weak base] callback in
            
            guard let base = base else { return Disposables.create() }
            
            base.migrate(upto: version, steps: steps, finalized: finalized) { result in
                result.runMaybeCallback(callback)
            }
            
            return Disposables.create()
        }
    }
}
