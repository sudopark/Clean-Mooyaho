//
//  EmojiInputTextFiled.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import RxSwift
import RxCocoa


public class EmojiInputTextFiled: UITextField {
    
    private let memojiInput = PublishSubject<UIImage>()
    public override var textInputContextIdentifier: String? { "" }
    
    public override var textInputMode: UITextInputMode? {
        return UITextInputMode.activeInputModes.first(where: { $0.primaryLanguage == "emoji" })
    }
    
    public override func paste(_ sender: Any?) {
        guard let image = UIPasteboard.general.image else { return }
        self.memojiInput.onNext(image)
    }
}


extension EmojiInputTextFiled {
    
    public var newInputMemoji: Observable<UIImage> {
        return self.memojiInput
    }
    
    public var newInputEmoji: Observable<String> {
        return self.rx.text.compactMap { text -> String? in
            guard let text = text, text.isEmpty == false else { return nil }
            
            let scaler = text.unicodeScalars
            let lastValue = scaler[scaler.index(before: scaler.endIndex)].value
            return lastValue.isEmoji ? text : nil
        }
    }
}

private extension UInt32 {
    
    var isEmoji: Bool {
        switch self {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F1E6...0x1F1FF, // Regional country flags
            0x2600...0x26FF,   // Misc symbols 9728 - 9983
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs 129280 - 129535
            0x1F018...0x1F270, // Various asian characters           127000...127600
            65024...65039, // Variation selector
            9100...9300, // Misc items
            8400...8447: // Combining Diacritical Marks for Symbols
            return true
               
        default: return false
        }
    }
}
