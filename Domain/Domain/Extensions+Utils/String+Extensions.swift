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
    
    public var isEmailAddress: Bool {
        let regexExpression = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", regexExpression)
        return predicate.evaluate(with: self)
    }
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(with args: Any...) -> String {
        let format = self.localized
        return String(format: format, args)
    }
}


// Levenshtein edit distance calculator(https://gist.github.com/bgreenlee/52d93a1d8fa1b8c1f38b)

extension String {
    
    private static func min(_ numbers: Int...) -> Int {
        return numbers.reduce(numbers[0], {$0 < $1 ? $0 : $1})
    }
    
    public static func levenshtein(aStr: String, bStr: String) -> Int {
        // create character arrays
        let a = Array(aStr)
        let b = Array(bStr)

        // initialize matrix of size |a|+1 * |b|+1 to zero
        var dist = [[Int]]()
        for _ in 0...a.count {
            dist += [Array(repeating: 0, count: b.count + 1)]
        }

        // 'a' prefixes can be transformed into empty string by deleting every char
        for i in 1...a.count {
            dist[i][0] = i
        }

        // 'b' prefixes can be created from empty string by inserting every char
        for j in 1...b.count {
            dist[0][j] = j
        }

        for i in 1...a.count {
            for j in 1...b.count {
                if a[i-1] == b[j-1] {
                    dist[i][j] = dist[i-1][j-1]  // noop
                } else {
                    dist[i][j] = String.min(
                        dist[i-1][j] + 1,  // deletion
                        dist[i][j-1] + 1,  // insertion
                        dist[i-1][j-1] + 1  // substitution
                    )
                }
            }
        }

        return dist[a.count][b.count]
    }

}
