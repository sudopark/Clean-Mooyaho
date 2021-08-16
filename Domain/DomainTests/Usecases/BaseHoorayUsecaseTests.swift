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
    var mockMemberRepository: MockMemberRepository!
    var sharedStore: SharedDataStoreServiceImple!
    var mockHoorayRepository: MockHoorayRepository!
    var mockMessagingService: MockMessagingService!
    var usecase: HoorayUsecaseImple!
    
    override func setUp() {
        super.setUp()
        self.disposeBag = .init()
        self.mockMemberRepository = .init()
        self.mockHoorayRepository = .init()
        self.mockMessagingService = .init()
        self.sharedStore = .init()
        let memberUsecase = MemberUsecaseImple(memberRepository: self.mockMemberRepository,
                                               sharedDataService: self.sharedStore)
        self.usecase = .init(authInfoProvider: sharedStore,
                             memberUsecase: memberUsecase,
                             hoorayRepository: self.mockHoorayRepository,
                             messagingService: self.mockMessagingService,
                             sharedStoreService: self.sharedStore)
    }
    
    override func tearDown() {
        self.disposeBag = nil
        self.mockMemberRepository = nil
        self.mockHoorayRepository = nil
        self.mockMessagingService = nil
        self.usecase = nil
        super.tearDown()
    }
}
