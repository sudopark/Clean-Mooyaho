//
//  StubApplicationUsecase.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit

@testable import MooyahoApp


class StubApplicationUsecase: ApplicationUsecase, Stubbable {
    
    func userFCMTokenUpdated(_ newToken: String?) {
        
    }
    
    func newNotificationReceived(_ userInfo: [AnyHashable : Any]) {
        
    }
    
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus) {
        
    }
    
    func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        return self.resolve(key: "loadLastSignInAccountInfo") ?? .empty()
    }
}
