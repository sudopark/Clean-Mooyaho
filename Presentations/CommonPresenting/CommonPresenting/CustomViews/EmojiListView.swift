//
//  EmojiListView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/13.
//

import UIKit

import RxSwift
import ISEmojiView


public final class EmojiListView: BaseUIView, Presenting {
    
    private var emojiView: EmojiView!
    private let selectedEmojiSubjct = PublishSubject<String>()
    
    public var selectedEmoji: Observable<String> {
        return self.selectedEmojiSubjct.asObservable()
    }
}

extension EmojiListView: EmojiViewDelegate {
    
    private func setupEmojiView() {
        let setting = KeyboardSettings(bottomType: .categories)
        self.emojiView = EmojiView(keyboardSettings: setting)
        self.emojiView.delegate = self
    }

    public func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        self.selectedEmojiSubjct.onNext(emoji)
    }
}

extension EmojiListView {
    
    public func setupLayout() {
        
        self.setupEmojiView()
        self.addSubview(emojiView)
        self.emojiView.autoLayout.fill(self)
    }
    
    public func setupStyling() { }
}
