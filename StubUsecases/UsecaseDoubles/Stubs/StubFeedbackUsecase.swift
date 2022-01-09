//
//  StubFeedbackUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2021/12/15.
//

import Foundation

import RxSwift

import Domain


public final class StubFeedbackUsecase: FeedbackUsecase {
    
    public init() { }
    
    public func leaveFeedback(contract: String, message: String) -> Maybe<Void> {
        return .just()
    }
}
