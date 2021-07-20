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
    
    var isNotificationGranted: Observable<Bool> { get }
    
    var currentFCMToken: Observable<String?> { get }
    
    var receiveNotificationUserInfo: Observable<[AnyHashable: Any]> { get }
}


extension FirebaseServiceImple: FCMService {
    
    public func setupFCMService() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { grant, _ in
            self.notificationAuthorizationGranted.onNext(grant)
            if grant {
                UIApplication.shared.registerForRemoteNotifications()
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
    
    public var receiveNotificationUserInfo: Observable<[AnyHashable : Any]> {
        return self.incommingNotificationUserInfo.asObservable()
    }
}

extension FirebaseServiceImple: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfo = notification.request.content.userInfo
        self.incommingNotificationUserInfo.onNext(userInfo)
        completionHandler([])
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        self.incommingNotificationUserInfo.onNext(userInfo)
        completionHandler()
    }
    
    public func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        self.fcmToken.onNext(fcmToken)
    }
}
