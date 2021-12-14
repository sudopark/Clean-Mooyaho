//
//  HelpRemoteImple+Firebase.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/12/15.
//

import Foundation

import RxSwift

import Domain
import DataStore


extension FirebaseServiceImple {
    
    public func requestLeaveFeedback(_ feedback: Feedback) -> Maybe<Void> {
        return self.save(feedback, at: .feedback)
    }
}
