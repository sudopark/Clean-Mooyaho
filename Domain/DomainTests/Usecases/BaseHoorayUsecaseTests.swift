//
//  BaseHoorayUsecaseTests.swift
//  DomainTests
//
//  Created by sudo.park on 2021/05/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import UnitTestHelpKit

@testable import Domain


class BaseHoorayUsecaseTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubMemberRepository: StubMemberRepository!
    var sharedStore: SharedDataStoreServiceImple!
    var stubHoorayRepository: StubHoorayRepository!
    var stubMessagingService: StubMessagingService!
    var usecase: HoorayUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.stubMemberRepository = .init()
        self.stubHoorayRepository = .init()
        self.stubMessagingService = .init()
        self.sharedStore = .init()
        let memberUsecase = MemberUsecaseImple(memberRepository: self.stubMemberRepository,
                                               sharedDataService: self.sharedStore)
        self.usecase = .init(authInfoProvider: self.sharedStore,
                             memberUsecase: memberUsecase,
                             hoorayRepository: self.stubHoorayRepository,
                             messagingService: self.stubMessagingService)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.stubMemberRepository = nil
        self.stubHoorayRepository = nil
        self.stubMessagingService = nil
        self.usecase = nil
        super.tearDown()
    }
}
