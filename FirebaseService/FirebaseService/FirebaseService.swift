//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import DataStore

public protocol FirebaseService {
    
    func setupService()
}

public final class FirebaseServiceImple: FirebaseService {
    
    let httpAPI: HttpAPI
    var fireStoreDB: Firestore!
    let serverKey: String
    let disposeBag = DisposeBag()
    
    public init(httpAPI: HttpAPI, serverKey: String) {
        self.httpAPI = httpAPI
        self.serverKey = serverKey
    }
    
    public func setupService() {
        
        FirebaseApp.configure()
        self.fireStoreDB = Firestore.firestore()
    }
}
