//
//  FireStore+Collections.swift
//  FirebaseService
//
//  Created by ParkHyunsoo on 2021/05/02.
//

import Foundation



enum FireStoreCollectionType: String {
    case member = "members"
}


extension Firestore {
    
    func collection(_ type: FireStoreCollectionType) -> CollectionReference {
        return self.collection(type.rawValue)
    }
}
