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



// MARK: - FirebaseServiceImple + ReadRemindMessagingService

extension FirebaseServiceImple: ReadRemindMessagingService {
    
    public func prepareNotificationPermission() -> Maybe<Bool> {
        
        let currentStatus = self.getCurrentPermission()
        
        let requestIfNeed: (UNAuthorizationStatus) -> Maybe<Bool> = { [weak self] status in
            guard let self = self else { return .empty() }
            return status == .notDetermined
                ? self.requestPermission()
                : status == .authorized ? .just(true)
                : .just(false)
        }
        return currentStatus
            .flatMap(requestIfNeed)
    }
    
    private func getCurrentPermission() -> Maybe<UNAuthorizationStatus> {
        return Maybe.create { callback in
            UNUserNotificationCenter.current().getNotificationSettings { setting in
                callback(.success(setting.authorizationStatus))
            }
            return Disposables.create()
        }
    }
    
    private func requestPermission() -> Maybe<Bool> {
        return Maybe.create { callback in
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { result, _ in
                callback(.success(result))
            }
            return Disposables.create()
        }
    }
    
    public var receivedMessage: Observable<Message> {
        return self.receivePushMessage
    }
    
    public func sendPendingMessage(_ message: ReadRemindMessage) -> Maybe<Void> {
        logger.todoImplement()
        return .just()
    }
    
    public func cancelMessage(for readMinderID: String) -> Maybe<Void> {
        logger.todoImplement()
        return .just()
    }
    
    public func broadcastRemind(_ message: ReadRemindMessage) -> Maybe<Void> {
        logger.todoImplement()
        return .just()
    }
}


// MARK: - FCMService

public protocol FCMService {
    
    func setupFCMService()
    
    func apnsTokenUpdated(_ token: Data)

    func didReceiveDataMessage(_ userInfo: [AnyHashable: Any])
    
    var isNotificationGranted: Observable<Bool> { get }
    
    var currentFCMToken: Observable<String?> { get }
    
    var receivePushMessage: Observable<Message> { get }
}

extension FirebaseServiceImple: FCMService {
    
    public func setupFCMService() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        self.prepareNotificationPermission()
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] grant in
                self?.notificationAuthorizationGranted.onNext(grant)
                UIApplication.shared.registerForRemoteNotifications()
            })
            .disposed(by: self.disposeBag)
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
