//
//  WaitNextHoorayViewModelTests.swift
//  HooraySceneTests
//
//  Created by sudo.park on 2021/06/06.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import StubUsecases

@testable import HoorayScene


class WaitNextHoorayViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var spyRouter: SpyRouter!
    var viewModel: WaitNextHoorayViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.spyRouter = .init()
        self.viewModel = .init(waitUntil: .now() + 100, router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}

extension WaitNextHoorayViewModelTests {
    
    // coutdown 시작
}


extension WaitNextHoorayViewModelTests {
    
    class SpyRouter: WaitNextHoorayRouting, Stubbable {
        
    }
}
