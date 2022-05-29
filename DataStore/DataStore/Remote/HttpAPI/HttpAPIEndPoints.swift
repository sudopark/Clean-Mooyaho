//
//  HttpAPIEndPoints.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - methods

public enum HttpAPIMethods: String {
    case get
    case post
    case patch
    case delete
}


// MARK: - end points

public protocol HttpAPIEndPoint {
    
    var path: String { get }
    var customHeader: [String: String]? { get }
    var method: HttpAPIMethods { get }
    var defaultParams: [String: Any]? { get }
}

extension HttpAPIEndPoint {
    public var customHeader: [String: String]? { nil }
    public var defaultParams: [String: Any]? { [:] }
}


// MARK: - Firebase Cloud Message request API

public struct FcmAPIEndPoint: HttpAPIEndPoint {
    
    private let serverKey: String
    public init(serverKey: String) {
        self.serverKey = serverKey
    }
    
    public var path: String {
        "https://fcm.googleapis.com/fcm/send"
    }
    
    public var method: HttpAPIMethods { .post }
    
    public var defaultParams: [String : Any]? {
        return [
            "Content-Type": "application/json",
            "Authorization": "key=\(self.serverKey)"
        ]
    }
}


public struct KakaoSignInAPIEndPoint: HttpAPIEndPoint {
    
    public let path: String
    public init(path: String) {
        self.path = "\(path)/kakao-signin"
    }
    
    public var method: HttpAPIMethods { .post }
    
    public var customHeader: [String : String]? {
        return [
            "Content-Type": "application/json",
        ]
    }
    
}


@available(*, deprecated, message: "use KakaoSignInAPIEndPoint")
public struct LegacyAPIEndPoint: HttpAPIEndPoint {
    
    public let path: String
    public init(path: String) {
        self.path = "\(path)/firebase_auth/kakao"
//        self.path = "http://localhost:8080/firebase_auth/kakao"
    }
    
    public var method: HttpAPIMethods { .post }
    public var customHeader: [String : String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
