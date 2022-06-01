//
//  MessagingRemote+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/19.
//

import Foundation

import RxSwift
import FirebaseFirestore

import Domain
import DataStore


extension FirebaseServiceImple { }


extension FirebaseServiceImple {
    
    func requestLoadOnlineUserDevices(_ userID: String) -> Maybe<[UserDevices]> {
        typealias Key = UserDeviceMappingKey
        let colllectionRef = self.fireStoreDB.collection(.userDevice)
        let query = colllectionRef
            .whereField(FieldPath.documentID(), isEqualTo: userID)
            .whereField(Key.isOnline.rawValue, isEqualTo: true)
        return self.load(query: query)
    }
    
    public func requestSendForground(message: Message, to userID: String) -> Maybe<Void> {
        
        guard let payload = (message as? MessagePayloadConvertable)?.asDataPayload() else {
            return .empty()
        }
        
        let loadOnlineDevices = self.requestLoadOnlineUserDevices(userID)
        let preparePayloads: ([UserDevices]) -> [String: Any] = { devices in
             return [
                "registration_ids": devices.map{ $0.token },
                "data": payload
            ]
        }
        let sendMessages: ([String: Any]) -> Maybe<Void> = { [weak self] payload in
            return self?.requestSendForgroundMessage(payload) ?? .empty()
        }
        
        return loadOnlineDevices
            .map(preparePayloads)
            .flatMap(sendMessages)
    }
    
    func batchSendForgroundMessages(_ message: Message, toUsers userIDs: [String]) {
        typealias Key = UserDeviceMappingKey
        
        guard let payload = (message as? MessagePayloadConvertable)?.asDataPayload() else { return }
        
        let collectionRef = self.fireStoreDB.collection(.userDevice)
        let slices = userIDs.slice(by: 10)
        let queries = slices.map { slice in
            return collectionRef.whereField(FieldPath.documentID(), in: slices)
                .whereField(Key.isOnline.rawValue, isEqualTo: true)
        }
        let onlineDevices: Observable<[UserDevices]> = self.loadAll(queries: queries)
        let asPayload: ([UserDevices]) -> [[String: Any]] = { devices in
            let sliceDevices = devices.slice(by: maxFcmSendrequestCount)
            return sliceDevices.map {
                [
                    "registration_ids": $0.compactMap{ $0.token },
                    "content_available": true,
                    "data": payload
                ]
            }
        }
        
        onlineDevices.map(asPayload)
            .subscribe(onNext: { [weak self] payloads in
                guard let self = self else { return }
                self.disposeBag.insert(
                    payloads.map{ self.requestSendForgroundMessage($0).subscribe() }
                )
            })
            .disposed(by: self.disposeBag)
    }
    
    private func requestSendForgroundMessage(_ payload: [String: Any]) -> Maybe<Void> {
        guard self.serverKey.isNotEmpty else { return .empty() }
        let endpoint = FcmAPIEndPoint(serverKey: self.serverKey)
        return self.httpAPI.requestResult(endpoint, parameters: payload)
    }
}
