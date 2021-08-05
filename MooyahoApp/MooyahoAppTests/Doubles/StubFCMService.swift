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

@testable import MooyahoApp


class StubFCMService: FCMService {
    
    var isNotificationGrant: Bool?
    
    func setupFCMService() {
        guard let isGrant: Bool = self.isNotificationGrant else { return }
        self.stubGrant.onNext(isGrant)
    }
    
    func apnsTokenUpdated(_ token: Data) { }
    
    private let stubGrant = PublishSubject<Bool>()
    func checkIsGranted() {
        guard let isGrant: Bool = self.isNotificationGrant else { return }
        self.stubGrant.onNext(isGrant)
    }
    
    var isNotificationGranted: Observable<Bool> {
        return stubGrant.asObservable()
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

