//
//  Reomte.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public enum RemoteErrors: Error {
    
    case notSupportCredential(_ type: String)
    case loadFail(_ type: String, reason: Error?)
    case saveFail(_ type: String, reason: Error?)
    case mappingFail(_ type: String)
}


public protocol Remote: AuthRemote { }
