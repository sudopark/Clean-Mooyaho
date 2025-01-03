//
//  SearchableQueryTokenStoreService.swift
//  Domain
//
//  Created by sudo.park on 2021/11/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics


// MARK: - SearchableQueryTokenStoreService

public protocol SuggestQueryEngine: Sendable {
    
    func insertTokens(_ texts: [String])
    
    func removeToken(_ text: String)
    
    func suggestSearchQuery(by keyword: String) -> Maybe<[String]>
    
    func clearAll()
}


public final class SuggestQueryEngineImple: SuggestQueryEngine, @unchecked Sendable {
    
    private let workName = "manage.search.queries"
    private var tokens: Set<String> = []
    
    public init() {}
}


extension SuggestQueryEngineImple {
    
    private var accessQueue: DispatchQueue {
        return DispatchQueue(label: self.workName)
    }
    
    public func insertTokens(_ texts: [String]) {
        self.accessQueue.sync {
            self.tokens = self.tokens.union(texts)
        }
    }
    
    public func removeToken(_ text: String) {
        self.accessQueue.sync {
            _ = self.tokens.remove(text)
        }
    }
    
    public func suggestSearchQuery(by keyword: String) -> Maybe<[String]> {
        let caculating: Maybe<[String]> = .create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            callback(.success(self.findingAction(keyword)))
            return Disposables.create()
        }
        let workSceheduleer: ConcurrentDispatchQueueScheduler = .init(queue: self.accessQueue)
        return caculating
            .subscribe(on: workSceheduleer)
    }
    
    private func findingAction(_ keyword: String) -> [String] {
        typealias MatchResult = (diffCount: Int, difference: Float, text: String)
        let postfiltering: (String) -> Bool = { $0.isNotEmpty }
        let calcualteResult: (String) -> MatchResult = { token in
            let diffCount = String.levenshtein(aStr: token, bStr: keyword)
            let difference = Float(diffCount) / Float(token.count)
            return MatchResult(diffCount, difference, token)
        }
        let exculudeMatchingBySimilarity: (MatchResult) -> Bool = { $0.difference < 0.9 }
        
        let ordering: (MatchResult, MatchResult) -> Bool = { lhs, rhs in
            
            let orderByDiff: () -> Bool = {
                switch (lhs.diffCount, rhs.diffCount) {
                case let (l, r) where l == r:
                    return lhs.difference < rhs.difference
                case let (l, r):
                    return l < r
                }
            }
            
            switch (lhs.text.starts(with: keyword), rhs.text.starts(with: keyword)) {
            case (false , true): return false
            case (true, false): return true
            default: return orderByDiff()
            }
        }

        return self.tokens
            .filter(postfiltering)
            .map(calcualteResult)
            .filter(exculudeMatchingBySimilarity)
            .sorted(by: ordering)
            .map { $0.text }
    }
    
    public func clearAll() {
        self.tokens.removeAll()
    }
}
