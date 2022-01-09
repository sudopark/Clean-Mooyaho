//
//  ReadPriority+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import Foundation

import Domain


extension ReadPriority {
    
    public var emoji: String {
        switch self {
        case .beforeDying: return "🧟‍♂️"
        case .someDay: return "👩‍🚀"
        case .thisWeek: return "📆"
        case .today: return "🎒"
        case .beforeGoToBed: return "🛌"
        case .onTheWaytoWork: return "🚌"
        case .afterAWhile: return "🎯"
        }
    }
    
    public var description: String {
        switch self {
        case .beforeDying: return "before dying".localized
        case .someDay: return "someday".localized
        case .thisWeek: return "this week".localized
        case .today: return "today".localized
        case .beforeGoToBed: return "before go to bed".localized
        case .onTheWaytoWork: return "on the way to work".localized
        case .afterAWhile: return "after a while".localized
        }
    }
}
