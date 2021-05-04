//
//  Array+Extensions.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/05.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


extension Array {
    
    public subscript(safe index: Int) -> Element? {
        guard (0..<self.count) ~= index else { return nil }
        return self[index]
    }
}
