//
//  ReactionView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/03.
//

import Foundation

import Domain


// MARK: - ReactionGroup

public struct ReactionGroup {
    
    public let key: String
    public let icon: ReactionIcon
    public var count: Int = 0
    public var isIncludeMine: Bool = false
    
    public init?(reactions: [HoorayReaction], isIncludeMine: Bool = false) {
        guard let first = reactions.first else { return nil }
        self.key = first.groupKey
        self.icon = first.icon
        self.count = reactions.count
        self.isIncludeMine = isIncludeMine
    }
}


// NARK: - ReactionView


extension HoorayReaction {
    
    public var groupKey: String {
        switch self.icon {
        case let .imageSource(source): return source.path
        case let .emoji(value): return value.encode()
        }
    }
}
