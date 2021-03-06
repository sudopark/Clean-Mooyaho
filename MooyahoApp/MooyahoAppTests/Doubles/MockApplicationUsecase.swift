//
//  MockApplicationUsecase.swift
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

@testable import Readmind


class MockApplicationUsecase: ApplicationUsecase, Mocking {
    
    func userFCMTokenUpdated(_ newToken: String?) {
        
    }
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus) {
        
    }
    
    func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        return self.resolve(key: "loadLastSignInAccountInfo") ?? .empty()
    }
    
    var currentSignedInMemeber: Observable<Member?> { .empty() }
    
    let signoutSubject = PublishSubject<Auth>()
    var signedOut: Observable<Auth> {
        return signoutSubject
            .asObservable()
    }
}
