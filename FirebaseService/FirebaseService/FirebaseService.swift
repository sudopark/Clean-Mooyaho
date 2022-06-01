//
//  FirebaseService.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Firebase
import FirebaseFirestore
import FirebaseStorage

import DataStore

public protocol FirebaseService {
    
    func setupService()
}

public final class FirebaseServiceImple: NSObject, FirebaseService {
    
    let httpAPI: HttpAPI
    var fireStoreDB: Firestore!
    var storage: Storage!
    let serverKey: String
    let disposeBag = DisposeBag()
    public var signInMemberID: String?
    let linkPreviewRemote: LinkPreviewRemote
    
    public init(httpAPI: HttpAPI, serverKey: String, previewRemote: LinkPreviewRemote) {
        self.httpAPI = httpAPI
        self.serverKey = serverKey
        self.linkPreviewRemote = previewRemote
    }
    
    public func setupService() {
        
        FirebaseApp.configure()
        self.fireStoreDB = Firestore.firestore()
        self.storage = Storage.storage()
    }
    
    // subjects for fcmService
    let notificationAuthorizationGranted = BehaviorSubject<Bool?>(value: nil)
    let fcmToken = BehaviorSubject<String?>(value: nil)
    let incommingDataMessageUserInfo = PublishSubject<[AnyHashable: Any]>()
}
