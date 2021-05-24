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
import UnitTestHelpKit

@testable import MooyahoApp


class StubApplicationUsecase: ApplicationUsecase, Stubbable {
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus) {
        
    }
}
