//
//  String+Extensions.swift
//  Domain
//
//  Created by sudo.park on 2021/09/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


extension String {
    
    public var isURLAddress: Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let range = NSRange(location: 0, length: self.utf16.count)
        let matches = detector.matches(in: self, options: [], range: range)

        return matches.isNotEmpty
    }
}
