//
//  StubReadingOptionUsecase.swift
//  UsecaseDoubles
//
//  Created by sudo.park on 2022/05/28.
//

import Foundation

import RxSwift

import Domain


open class StubReadingOptionUsecase: ReadingOptionUsecase {
    
    public struct Scenario {
        public var loadLastReadPositionResult: Result<Float?, Error> = .success(nil)
        public var updateLastReadPositionResult: Result<Bool, Error> = .success(true)
        public var isEnableLastReadPositionSaveOption = true
        public init() {}
    }
    
    public var scenario: Scenario
    
    public init(scenario: Scenario? = nil) {
        self.scenario = scenario ?? .init()
    }
    
    public func lastReadPosition(for itemID: String) -> Maybe<Float?> {
        return self.scenario.loadLastReadPositionResult.asMaybe()
    }
    
    public var didSavedReadPosiiton: Float?
    
    public func updateLastReadPositionIsPossible(for itemID: String, position: Float) -> Maybe<Bool> {
        self.didSavedReadPosiiton = position
        return self.scenario.updateLastReadPositionResult.asMaybe()
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) {
        self.scenario.isEnableLastReadPositionSaveOption = isOn
    }
    
    public func isEnabledLastReadPositionSaveOption() -> Observable<Bool> {
        return .just(self.scenario.isEnableLastReadPositionSaveOption)
    }
}

