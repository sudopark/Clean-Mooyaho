//
//  ReadingOptionUsecase.swift
//  Domain
//
//  Created by sudo.park on 2022/05/28.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxSwiftDoNotation


// MARK: - ReadingOptionUsecase

public protocol ReadingOptionUsecase: AnyObject {
    
    func lastReadPosition(for itemID: String) -> Maybe<ReadPosition?>
    
    func updateLastReadPositionIsPossible(for itemID: String, position: Double) -> Maybe<ReadPosition>
    
    func updateEnableLastReadPositionSaveOption(_ isOn: Bool)
    
    func isEnabledLastReadPositionSaveOption() -> Observable<Bool>
}


// MARK: - ReadingOptionUsecaseImple

public final class ReadingOptionUsecaseImple: ReadingOptionUsecase {
    
    private let readingOptionRepository: ReadingOptionRepository
    private let sharedDataStore: SharedDataStoreService
    
    private struct OptionSet {
        var lastReadPosition: Bool?
    }
    
    public init(
        readingOptionRepository: ReadingOptionRepository,
        sharedDataStore: SharedDataStoreService
    ) {
        self.readingOptionRepository = readingOptionRepository
        self.sharedDataStore = sharedDataStore
    }
}


extension ReadingOptionUsecaseImple {
    
    public func lastReadPosition(for itemID: String) -> Maybe<ReadPosition?> {
        
        guard self.prepareLastReadPositionOption() == true
        else {
            return .just(nil)
        }
        
        return self.readingOptionRepository.fetchLastReadPosition(for: itemID)
    }
    
    public func updateLastReadPositionIsPossible(for itemID: String,
                                                 position: Double) -> Maybe<ReadPosition> {
        guard self.prepareLastReadPositionOption() == true
        else {
            return .error(RuntimeError("save last read position option is disabled"))
        }
        logger.print(level: .debug, "will update last read position: \(itemID) at: \(position)")
        return self.readingOptionRepository.updateLastReadPosition(for: itemID, position)
    }
    
    public func updateEnableLastReadPositionSaveOption(_ isOn: Bool) {
        
        self.readingOptionRepository.updateEnableLastReadPositionSaveOption(isOn)
        self.sharedDataStore
            .update(Bool.self, key: SharedDataKeys.saveLastReadPosition.rawValue, value: isOn)
    }
    
    public func isEnabledLastReadPositionSaveOption() -> Observable<Bool> {
        
        let key = SharedDataKeys.saveLastReadPosition
        
        let refreshIsOn: () -> Void = { [weak self] in
            guard let self = self else { return }
            let isOn = self.readingOptionRepository.isEnabledLastReadPositionSaveOption()
            self.sharedDataStore.update(Bool.self, key: key.rawValue, value: isOn)
        }
        
        return self.sharedDataStore
            .observe(Bool.self, key: key.rawValue)
            .do(onSubscribed: refreshIsOn)
            .compactMap { $0 }
            .distinctUntilChanged()
    }

    private func prepareLastReadPositionOption() -> Bool {
        
        let key = SharedDataKeys.saveLastReadPosition

        return self.sharedDataStore.fetch(Bool.self, key: key)
            ?? self.readingOptionRepository.isEnabledLastReadPositionSaveOption()
    }
}
