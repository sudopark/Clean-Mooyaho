//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol FirebaseService {
    
    func setupService()
}

public class FirebaseServiceImple: FirebaseService {
    
    var fireStoreDB: Firestore!
    
    public init() {}
    
    public func setupService() {
        
        FirebaseApp.configure()
        self.fireStoreDB = Firestore.firestore()
    }
}
