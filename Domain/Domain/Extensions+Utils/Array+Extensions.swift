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
    
    public func removeDuplicated<K: Hashable>(keySelector: (Element) -> K) -> Self {
        let orderPairMap = self.enumerated().reduce(into: [K: (offset: Int, element: Element)]()) { acc, pair in
            
            let key = keySelector(pair.element)
            if acc[key] == nil {
                acc[key] = pair
            }
        }
        
        return orderPairMap.sorted(by: { $0.value.offset < $1.value.offset })
            .map{ $0.value.element }
    }
    
    public func slice(by size: Int) -> [Array] {
        let sectionSize = self.count / size + 1
        return (0..<sectionSize).reduce(into: [Array]()) { acc, sectionIndex in
            let start = sectionIndex * size
            let end = Swift.min(self.count, start + size)
            let slice = Array(self[start..<end])
            acc.append(slice)
        }
        .filter{ $0.isNotEmpty }
    }
}

