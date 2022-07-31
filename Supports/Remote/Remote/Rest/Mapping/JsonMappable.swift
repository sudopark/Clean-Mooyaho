//
//  JsonMappable.swift
//  Remote
//
//  Created by sudo.park on 2022/07/12.
//

import Foundation
import Prelude
import Optics
import Extensions


public protocol JsonPresentable {
    
    var identifier: String { get }
    func asJson() -> [String: Any]
}


public protocol JsonMappable {
    
    static var identifierKey: String { get }
    
    init(json: [String: Any]) throws
}

public protocol JsonConvertable: JsonPresentable, JsonMappable { }



extension Dictionary where Self.Key == String, Self.Value == Any {
    
    public func value<R: RawRepresentable, T>(_ key: R) throws -> T where R.RawValue == String {
        guard let value = self[key.rawValue] as? T
        else {
            throw RuntimeError("mapping fail, value not exists for key: \(key)")
        }
        return value
    }
}
