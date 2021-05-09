//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import DataStore

public protocol FirebaseService {
    
    func setupService()
}

public final class FirebaseServiceImple: FirebaseService {
    
    let httpAPI: HttpAPI
    var fireStoreDB: Firestore!
    
    public init(httpAPI: HttpAPI) {
        self.httpAPI = httpAPI
    }
    
    public func setupService() {
        
        FirebaseApp.configure()
        self.fireStoreDB = Firestore.firestore()
    }
}
