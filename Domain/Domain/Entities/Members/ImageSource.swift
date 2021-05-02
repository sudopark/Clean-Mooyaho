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
    
    public var sourcePath: String {
        switch self {
        case let .path(value),
             let .reference(value, _):
            return value
        }
    }
}
