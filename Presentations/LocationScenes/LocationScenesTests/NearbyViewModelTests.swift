//
//  NearbyViewModelTests.swift
//  LocationScenesTests
//
//  Created by sudo.park on 2021/05/23.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit
import StubUsecases

@testable import LocationScenes


class NearbyViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var stubLocationUsecase: StubUserLocationUsecase!
    var spyRouter: SpyRouter!
    var viewModel: NearbyViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.stubLocationUsecase = .init()
        self.spyRouter = .init()
        self.viewModel = NearbyViewModelImple(locationUsecase: self.stubLocationUsecase,
                                              router: self.spyRouter)
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.stubLocationUsecase = nil
        self.spyRouter = nil
        self.viewModel = nil
    }
}


extension NearbyViewModelTests {
    
    
}

extension NearbyViewModelTests {
    
    class SpyRouter: NearbyRouting {
        
        
    }
}
