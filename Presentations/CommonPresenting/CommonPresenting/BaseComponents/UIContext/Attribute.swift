//
//  Attribute.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/07/04.
//

import UIKit


public enum Attribute {
    
    public static var placeHolder: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.gray,
            .font: UIFont.systemFont(ofSize: 13.5)
        ]
    }
    
    public static var accent: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.systemBlue,
            .font: UIFont.systemFont(ofSize: 14)
        ]
    }
    
    public static var tagPlaceHolder: NSAttributedString {
        return "Enter tags".with(attribute: self.placeHolder)
    }
    
    public static func tagAttributeText(for tags: [String]) -> NSAttributedString {
        let tagWords = tags.map{ "#\($0)" }
        let allTagTexts = tagWords.joined(separator: " ")
        return allTagTexts.with(attribute: self.accent)
    }
    
    public static func keyAndValue(_ key: String,
                                   _ keyword: String?) -> NSAttributedString {
        let phrase = "\(key)   ".with(attribute: self.placeHolder)
        let attrKeyword = keyword?.with(attribute: self.accent)
        let mutable = NSMutableAttributedString(attributedString: phrase)
        guard let attr = attrKeyword else {
            return mutable
        }
        mutable.append(attr)
        return mutable
    }
}
