//
//  ImageSource.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public enum ImageSource {
    
    case path(_ path: String)
    case reference(_ path: String, description: String?)
    case emoji(_ rawValue: String)
    
    public var sourcePath: String? {
        switch self {
        case let .path(value),
             let .reference(value, _):
            return value
        default:
            return nil
        }
    }
}


extension ImageSource: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.path(p1), .path(p2)): return p1 == p2
        case let (.reference(p1, d1), .reference(p2, d2)): return p1 == p2 && d1 == d2
        case let (.emoji(v1), .emoji(v2)): return v1 == v2
        default: return false
        }
    }
}
