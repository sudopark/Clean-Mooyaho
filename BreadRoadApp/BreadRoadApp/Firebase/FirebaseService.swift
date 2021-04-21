//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Firebase


protocol FirebaseServiceInterface {
    
    func setup()
}


class FirebaseService: FirebaseServiceInterface {
    
    func setup() {
        FirebaseApp.configure()
        
//        // make crash
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            fatalError()
//        }
    }
}
