//
//  Notification+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/27.
//

import UIKit

import RxSwift


public struct KeyboardFrameChanges: Equatable {
    
    public enum EventType:Equatable {
        case show
//        case change
        case hide
    }
    
    public let type: EventType
    public let from: CGRect
    public let to: CGRect
    public let duration: TimeInterval
}


extension Reactive where Base == NotificationCenter {
    
    @MainActor
    public var keyboardFrameWillChanges: Observable<KeyboardFrameChanges> {
        
        let willShow = base.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap{ $0.keyboardChanges(.show) }
        let willChangeAsShow = base.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .compactMap{ $0.keyboardChanges(.show) }
        let willHide = base.rx.notification(UIResponder.keyboardWillHideNotification)
            .compactMap{ $0.keyboardChanges(.hide) }

        return Observable.merge(
            Observable.merge(willShow, willChangeAsShow).distinctUntilChanged(),
            willHide
        )
    }
}


extension Notification {
    
    @MainActor
    func keyboardChanges(_ type: KeyboardFrameChanges.EventType) -> KeyboardFrameChanges? {
        
        guard let from = self.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect,
              let to = self.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = self.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return nil
        }
        return .init(type: type, from: from, to: to, duration: duration)
    }
}
