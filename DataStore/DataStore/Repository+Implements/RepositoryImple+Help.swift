//
//  RepositoryImple+Help.swift
//  DataStore
//
//  Created by sudo.park on 2021/12/15.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol HelpReposiotryDefImpleDependency: AnyObject {
    
    var helpRemote: HelpRemote { get }
}


extension HelpRepository where Self: HelpReposiotryDefImpleDependency {
    
    public func leaveFeedback(_ feedback: Feedback) -> Maybe<Void> {
        return self.helpRemote.requestLeaveFeedback(feedback)
    }
}
