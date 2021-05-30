//
//  SignInViewModelTests.swift
//  MemberScenesTests
//
//  Created by sudo.park on 2021/05/30.
//

import XCTest

import RxSwift

import Domain
import StubUsecases
import UnitTestHelpKit

@testable import MemberScenes


class SignInViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubAuthUsecase: StubAuthUsecase!
    var spyRouter: SpyRouter!
    var viewModel: SignInViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.stubAuthUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = .init(authUsecase: self.stubAuthUsecase,
                               router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubAuthUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension SignInViewModelTests {
    
    
}


extension SignInViewModelTests {
    
    class SpyRouter: SignInRouting, Stubbable {
        
    }
}
