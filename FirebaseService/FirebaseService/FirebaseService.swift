//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

//import Firebase

public class FirebaseService {
    
    public init() {}
    
    public func setup() {
        
        FirebaseApp.configure()
    }
}


extension FirebaseService {
    
    public func signInAnonymously() {
        Auth.auth().signInAnonymously { result, error in
            print("result: \(result?.user.uid) and error: \(error)")
        }
    }
}
