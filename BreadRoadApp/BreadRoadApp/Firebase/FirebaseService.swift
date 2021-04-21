//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


class FirebaseService {
    
    func setup() {
        
        FirebaseApp.configure()
        
//        // make crash
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            fatalError()
//        }
    }
}


extension FirebaseService {
    
    func signInAnonymously() {
        Auth.auth().signInAnonymously { result, error in
            print("result: \(result?.user.uid) and error: \(error)")
        }
    }
}
