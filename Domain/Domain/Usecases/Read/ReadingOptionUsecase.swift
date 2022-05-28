//
//  ReadingOptionUsecase.swift
//  Domain
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


// MARK: - ReadingOptionUsecase

public protocol ReadingOptionUsecase: AnyObject {
    
    func lastReadPosition(for itemID: String) -> Maybe<Float?>
    
    func updateLastReadPosition(for itemID: String, position: Float) -> Maybe<Void>
    
    func updateEnableLastReadPositionSaveOption(_ isOn: Bool) -> Maybe<Void>
    
    func isEnabledLastReadPositionSaveOption() -> Observable<Bool>
}


// MARK: - ReadingOptionUsecaseImple

public final class ReadingOptionUsecaseImple: ReadingOptionUsecase {
    
    public init() {
        
    }
}


extension ReadingOptionUsecaseImple {
    
    public func lastReadPosition(for itemID: String) -> Maybe<Float?> {
        return .just(nil)
    }
    
    public func updateLastReadPosition(for itemID: String, position: Float) -> Maybe<Void> {
        return .just()
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) -> Maybe<Void> {
        return .just()
    }
    
    public func isEnabledLastReadPositionSaveOption() -> Observable<Bool> {
        return .just(true)
    }
}
