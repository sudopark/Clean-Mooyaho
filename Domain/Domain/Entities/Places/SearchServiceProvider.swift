//
//  SearchServiceProvider.swift
//  Domain
//
//  Created by sudo.park on 2021/06/12.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - SearchServiceProvider

public protocol SearchServiceProvider {
    
    var serviceName: String { get }
    var link: String? { get }
    var logo: ImageSource? { get }
}


// MARK: - SearchServiceProviders

public enum SearchServiceProviders: SearchServiceProvider {
    
    case naver
    
    public var serviceName: String {
        switch self {
        case .naver: return "Naver map"
        }
    }
    
    public var link: String? {
        return nil
    }
    
    public var logo: ImageSource? {
        return nil
    }
}
