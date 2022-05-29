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
        public var loadLastReadPositionResult: Result<ReadPosition?, Error> = .success(nil)
        public var updateLastReadPositionResult: Result<ReadPosition, Error> = .success(ReadPosition(itemID: "some", position: 30))
        public var isEnableLastReadPositionSaveOption = true
        public init() {}
    }
    
    public var scenario: Scenario
    
    public init(scenario: Scenario? = nil) {
        self.scenario = scenario ?? .init()
    }
    
    public func lastReadPosition(for itemID: String) -> Maybe<ReadPosition?> {
        return self.scenario.loadLastReadPositionResult.asMaybe()
    }
    
    public var didSavedReadPosiiton: Double?
    public func updateLastReadPositionIsPossible(for itemID: String, position: Double) -> Maybe<ReadPosition> {
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

