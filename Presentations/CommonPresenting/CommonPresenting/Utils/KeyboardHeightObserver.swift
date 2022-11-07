//
//  KeyboardHeightObserver.swift
//  CommonPresenting
//
//  Created by sudo.park on 2022/11/08.
//

import UIKit
import Combine


@MainActor
public final class KeyboardHeightObserver: ObservableObject {
    
    @Published public var showingKeyboardHeight: CGFloat = 0
    public var isVisible: Bool {
        return self.showingKeyboardHeight > 0
    }
    
    private var observing: Cancellable?
    
    public init() {
        self.observeHeight()
    }
    
    private func observeHeight() {
     
        let willShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.keyboardChanges(.show) }
        let willHide = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillHideNotification)
            .compactMap { $0.keyboardChanges(.hide) }
        let willChangeAsShow = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { $0.keyboardChanges(.show) }
        
        let changes = Publishers.Merge(
            Publishers.Merge(willShow, willChangeAsShow).removeDuplicates(),
            willHide
        )
        
        self.observing = changes
            .sink(receiveValue: { [weak self] change in
                let showingHeight = change.type == .show ? change.to.height : 0
                self?.showingKeyboardHeight = showingHeight
            })
    }
}
