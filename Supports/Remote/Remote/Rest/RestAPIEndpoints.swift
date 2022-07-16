//
//  RestAPIEndpoints.swift
//  Remote
//
//  Created by sudo.park on 2022/07/12.
//

import Foundation


// MARK: - end points

public protocol RestAPIEndpoint {
    
    var path: String { get }
    var header: [String: String]? { get }
    var method: HttpAPIMethod { get }
}

extension RestAPIEndpoint {
    
    public var header: [String: String]? { nil }
}
