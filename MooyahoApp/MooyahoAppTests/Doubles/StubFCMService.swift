//
//  StubFCMService.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/07/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import FirebaseService

@testable import Readmind


class StubFCMService: FCMService {
    
    var isNotificationGrant: Bool?
    var fakeGrant = PublishSubject<Bool>()
    
    func setupFCMService() {
        guard let isGrant: Bool = self.isNotificationGrant else { return }
        self.fakeGrant.onNext(isGrant)
    }
    
    func apnsTokenUpdated(_ token: Data) { }
    
    var isNotificationGranted: Observable<Bool> {
        return self.fakeGrant.asObservable()
    }
    
    let stubToken = PublishSubject<String?>()
    var currentFCMToken: Observable<String?> {
        return stubToken.asObservable()
    }
    
    let mockPushMessages = PublishSubject<Message>()
    var receivePushMessage: Observable<Message> {
        return self.mockPushMessages.asObservable()
    }
    
    func didReceiveDataMessage(_ userInfo: [AnyHashable : Any]) {
        
    }
}

