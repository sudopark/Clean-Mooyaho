//
//  Time+Extension.swift
//  Domain
//
//  Created by sudo.park on 2021/10/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


extension TimeStamp {
    
    public func remindTimeText() -> String {
        
        let form = DateFormatter()
        form.dateFormat = "MMM d, yyyy, H:mm".localized
        return form.string(from: Date(timeIntervalSince1970: self))
    }
    
    public func dateText() -> String {
        
        let form = DateFormatter()
        form.dateFormat = "MM.d"
        return form.string(from: Date(timeIntervalSince1970: self))
    }
}
