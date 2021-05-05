//
//  HttpAPIEndPoints.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - methods

enum HttpAPIMethods: String {
    case get
    case post
    case patch
    case delete
}


// MARK: - end points

protocol HttpAPIEndPoint {
    
    var path: String { get }
    var header: [String: Any] { get }
    var method: HttpAPIMethods { get }
    var defaultParams: [String: Any] { get }
}

extension HttpAPIEndPoint {
    var header: [String: Any] { [:] }
    var defaultParams: [String: Any] { [:] }
}


// MARK: - naver place http endpoint


enum NaverMapPlaceAPIEndPoint: HttpAPIEndPoint {
    
    case places
    
    var path: String {
        return "https://map.naver.com/v5/api/search"
    }
    
    var method: HttpAPIMethods {
        return .get
    }
    
    var defaultParams: [String : Any] {
        return [
            "lang": "ko",
            "caller": "pcweb",
            "types": "place"
        ]
    }
}
