//
//  FeedbackUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/12/14.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


public protocol FeedbackUsecase {
    
    func leaveFeedback(contract: String, message: String) -> Maybe<Void>
}


public final class FeedbackUsecaseImple: FeedbackUsecase {
    
    private let authProvider: AuthInfoProvider
    private let deviceInfoService: DeviceInfoService
    private let helpRepository: HelpRepository
    
    public init(authProvider: AuthInfoProvider,
                deviceInfoService: DeviceInfoService,
                helpRepository: HelpRepository) {
        
        self.authProvider = authProvider
        self.deviceInfoService = deviceInfoService
        self.helpRepository = helpRepository
    }
}


extension FeedbackUsecaseImple {
    
    public func leaveFeedback(contract: String, message: String) -> Maybe<Void> {
        
        guard let userID = self.authProvider.currentAuth()?.userID else {
            return .error(ApplicationErrors.noUserInfo)
        }
        let isiOSAppOnMac:Bool?
        if #available(iOS 14.0, *) {
            isiOSAppOnMac = ProcessInfo.processInfo.isiOSAppOnMac
        } else {
            isiOSAppOnMac = nil
        }
        
        var feedback = Feedback(userID: userID)
        feedback.appVersion = self.deviceInfoService.appVersion()
        feedback.osVersion = self.deviceInfoService.osVersion()
        feedback.deviceModel = self.deviceInfoService.deviceModel()
        feedback.message = message
        feedback.contract = contract
        feedback.isiOSAppOnMac = isiOSAppOnMac
        return self.helpRepository.leaveFeedback(feedback)
    }
}
