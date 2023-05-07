//
//  HelpRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/12/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol HelpRepository: Sendable {
    
    func leaveFeedback(_ feedback: Feedback) -> Maybe<Void>
}
