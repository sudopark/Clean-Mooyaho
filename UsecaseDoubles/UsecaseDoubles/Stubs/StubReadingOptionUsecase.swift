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
        public var updateLastReadPositionResult: Result<Void, Error> = .success(())
        public var updateEnableLastReadPositionResult: Result<Void, Error> = .success(())
        
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
    
    public func updateLastReadPosition(for itemID: String, position: Float) -> Maybe<Void> {
        self.didSavedReadPosiiton = position
        return self.scenario.updateLastReadPositionResult.asMaybe()
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) -> Maybe<Void> {
        return self.scenario.updateEnableLastReadPositionResult.asMaybe()
            .do(onNext: {
                self.isOnLastReadPositionSaveOption.onNext(isOn)
            })
    }
    
    private let isOnLastReadPositionSaveOption = BehaviorSubject<Bool>(value: true)
    
    public func isEnabledLastReadPositionSaveOption() -> Observable<Bool> {
        return self.isOnLastReadPositionSaveOption.asObservable()
    }
}

