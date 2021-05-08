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
    
    let httpRemote: HttpRemote
    var fireStoreDB: Firestore!
    
    public init(httpRemote: HttpRemote) {
        self.httpRemote = httpRemote
    }
    
    public func setupService() {
        
        FirebaseApp.configure()
        self.fireStoreDB = Firestore.firestore()
    }
}
