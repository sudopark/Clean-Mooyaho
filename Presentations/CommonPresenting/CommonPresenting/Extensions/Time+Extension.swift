//
//  Time+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/08/13.
//

import Foundation


extension TimeInterval {
    
    private var minute: TimeInterval { 60 * 1000 }
    
    private var hour: TimeInterval { minute * 60 }
    
    private var day: TimeInterval { hour * 24 }
    
    private var week: TimeInterval { day * 7 }
    
    private var month: TimeInterval { day * 31 }
    
    private var year: TimeInterval { day * 365 }
    
    private func divide(_ unit: TimeInterval) -> Int {
        return Int(self / unit)
    }
    
    public var timeAgoText: String {
        
        let interval = TimeInterval.now() - self
        switch interval {
        case 0..<minute:
            return "now".localized
            
        case minute..<hour:
            return "minute_ago".localized(with: self.divide(minute))
            
        case hour..<day:
            return "hour_ago".localized(with: self.divide(hour))
            
        case day..<week:
            return "day_ago".localized(with: self.divide(day))
            
        case week..<month:
            return "week_ago".localized(with: self.divide(week))
            
        case year...:
            return "year_ago".localized(with: self.divide(year))
            
        default: return ""
        }
    }
}
