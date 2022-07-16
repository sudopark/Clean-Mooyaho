//
//  JsonMappable.swift
//  Remote
//
//  Created by sudo.park on 2022/07/12.
//

import Foundation
import Prelude
import Optics


public protocol JsonPresentable {
    
    var identifier: String { get }
    func asJson() -> [String: Any]
}


public protocol JsonMappable {
    
    static var identifierKey: String { get }
    
    init(json: [String: Any]) throws
}

public protocol JsonConvertable: JsonPresentable, JsonMappable { }

