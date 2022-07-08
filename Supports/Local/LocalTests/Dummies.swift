//
//  Dummies.swift
//  LocalTests
//
//  Created by sudo.park on 2022/07/09.
//

import Foundation


struct Dummy: Codable, Equatable {
    
    enum CodingKeys: String, CodingKey {
        case int
        case some
    }
    
    var int: Int
    var some: String
    
    init(_ int: Int, _ some: String) {
        self.int = int
        self.some = some
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.int = try container.decode(Int.self, forKey: .int)
        self.some = try container.decode(String.self, forKey: .some)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.int, forKey: .int)
        try container.encode(self.some, forKey: .some)
    }
}
