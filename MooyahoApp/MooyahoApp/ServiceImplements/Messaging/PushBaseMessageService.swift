//
//  PushBaseMessageService.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/07/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


final class PushBaseMessageService {
    
    private let receivePushMessage = PublishSubject<Message>()
    private let disposeBag = DisposeBag()
    
    init(pushMessageSource: Observable<Message>) {
        
        pushMessageSource
            .subscribe(onNext: { [weak self] message in
                self?.receivePushMessage.onNext(message)
            })
            .disposed(by: self.disposeBag)
    }
}


extension PushBaseMessageService: MessagingService {
    
    var receivedMessage: Observable<Message> {
        return self.receivePushMessage.asObservable()
    }
}
