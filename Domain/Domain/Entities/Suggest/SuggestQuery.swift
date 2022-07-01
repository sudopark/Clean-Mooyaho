//
//  SuggestQuery.swift
//  Domain
//
//  Created by sudo.park on 2021/11/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation
import Extensions


public protocol SuggestQuery {
    
    var text: String { get }
    
    var customCompareKey: Int { get }
}

public struct LatestSearchedQuery: SuggestQuery {
    
    public let text: String
    public let searchedTime: TimeStamp
    
    public init(text: String, time: TimeStamp) {
        self.text = text
        self.searchedTime = time
    }
    
    public var customCompareKey: Int {
        var hasher = Hasher()
        hasher.combine("latest")
        hasher.combine(self.text)
        hasher.combine(searchedTime)
        return hasher.finalize()
    }
}


public struct MayBeSearchableQuery: SuggestQuery {
    
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
    public var customCompareKey: Int {
        var hasher = Hasher()
        hasher.combine("suggest")
        hasher.combine(text)
        return hasher.finalize()
    }
}
