//
//  MainViewModelTests.swift
//  MooyahoAppTests
//
//  Created by sudo.park on 2021/05/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import LocationScenes
import UnitTestHelpKit

@testable import MooyahoApp


class MainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    var viewModel: MainViewModelImple!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.viewModel = .init(router: SpyRouter())
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.viewModel = nil
    }
}


extension MainViewModelTests {
    
   
}


extension MainViewModelTests {
    
    class SpyRouter: MainRouting, Stubbable {
        
        func addNearbySceen(_ eventSignal: @escaping EventSignal<NearbySceneEvents>) {
            
        }
        
        func openSlideMenu() {
            
        }
    }
}
