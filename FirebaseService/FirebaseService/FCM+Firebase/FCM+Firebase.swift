//
//  MessagingService+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/07/20.
//

import UIKit

import RxSwift
import RxRelay

import Domain


public protocol FCMService {
    
    func setupFCMService()
    
    func apnsTokenUpdated(_ token: Data)
    
    func checkIsGranted()
    
    func didReceiveDataMessage(_ userInfo: [AnyHashable: Any])
    
    var isNotificationGranted: Observable<Bool> { get }
    
    var currentFCMToken: Observable<String?> { get }
    
    var receivePushMessage: Observable<Message> { get }
}


extension FirebaseServiceImple: FCMService {
    
    public func setupFCMService() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { grant, _ in
            self.notificationAuthorizationGranted.onNext(grant)
            if grant {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    public func checkIsGranted() {
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { setting in
            switch setting.authorizationStatus {
            case .denied:
                self.notificationAuthorizationGranted.onNext(false)
            case .authorized:
                self.notificationAuthorizationGranted.onNext(true)
            default: break
            }
        })
    }
    
    public func apnsTokenUpdated(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }
    
    public var isNotificationGranted: Observable<Bool> {
        return self.notificationAuthorizationGranted.compactMap{ $0 }
    }
    
    public var currentFCMToken: Observable<String?> {
        return self.fcmToken.asObservable()
    }

    public var receivePushMessage: Observable<Message> {
        
        let convertAsMessage: ([AnyHashable: Any]) -> Message? = { [weak self] userInfo in
            guard let dataPayload = userInfo as? [String: Any] else { return nil }
            return self?.decodeMessagePayload(dataPayload)
        }
        
        return self.incommingDataMessageUserInfo
            .compactMap(convertAsMessage)
    }
    
    private func decodeMessagePayload(_ payload: [String: Any]) -> Message? {
        let typeKey = BasePushPayloadMappingKey.messageTypeKey
        guard let typeRawValue = payload[typeKey] as? String,
              let type = PushMessagingTypes(rawValue: typeRawValue) else { return nil }
        switch type {
        case .hoorayAck:
            return HoorayAckMessage(payload)
        }
    }
}

extension FirebaseServiceImple: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public func didReceiveDataMessage(_ userInfo: [AnyHashable: Any]) {
        self.incommingDataMessageUserInfo.onNext(userInfo)
    }
    
//    public func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                       willPresent notification: UNNotification,
//                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        let userInfo = notification.request.content.userInfo
//        self.incommingNotificationUserInfo.onNext(userInfo)
//        completionHandler([])
//    }
//
//    public func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                       didReceive response: UNNotificationResponse,
//                                       withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        let userInfo = response.notification.request.content.userInfo
//        self.incommingNotificationUserInfo.onNext(userInfo)
//        completionHandler()
//    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.fcmToken.onNext(fcmToken)
    }
}
