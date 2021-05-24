//
//  ApplicationUsecase.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain


public enum ApplicationStatus {
    case idle
    case forground
    case background
    case terminate
}

public protocol ApplicationUsecase {
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus)
}

public final class ApplicationUsecaseImple: ApplicationUsecase {
    
    private let authUsecase: AuthUsecase
    private let memberUsecase: MemberUsecase
    private let locationUsecase: UserLocationUsecase
    
    public init(authUsecase: AuthUsecase,
                memberUsecase: MemberUsecase,
                locationUsecase: UserLocationUsecase) {
        self.authUsecase = authUsecase
        self.memberUsecase = memberUsecase
        self.locationUsecase = locationUsecase
    }
    
    fileprivate struct Subjects {
        let applicationStatus = BehaviorRelay<ApplicationStatus>(value: .idle)
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


extension ApplicationUsecaseImple {
    
    public func updateApplicationActiveStatus(_ newStatus: ApplicationStatus) {
        
    }
}
