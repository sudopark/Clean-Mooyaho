//
//  HoorayPublisherUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/05/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - HoorayPublisherUsecase

public protocol HoorayPublisherUsecase { }


// MARK: - HoorayPublishUsecaseImple

public final class HoorayPublishUsecaseImple { }


extension HoorayPublishUsecaseImple {
    
    public func isAvailToPublish(_ memberID: String) -> Maybe<Bool> {
        // TODO: 무야호 쏠수있는지 조회
        return .empty()
    }
    
    public func publish(newHooray hooray: NewHoorayForm) -> Maybe<Hooray> {
         
        // TODO: 새 후레이 생성해서 초기 수신받은 유저 아이디 목록 반영되어있음 + 유저별 지속시간, 영향 범위 담겨있음
        return .empty()
    }
    
    public func publish(newHooray hooray: NewHoorayForm,
                        at newPlace: NewPlaceForm) -> Maybe<Hooray> {
        
        // TODO: 신규장소 등록과 함께 무야호
        return .empty()
    }
}


extension HoorayPublishUsecaseImple {
    
    var receiveHoorayReaction: Observable<HoorayReaction> {
        // TODO: Hooray 반응 모델링 및 구현 필요
        return .empty()
    }
}
