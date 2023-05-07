//
//  InputKeyboardHandlable.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/27.
//

import UIKit

import RxSwift
import RxCocoa


@MainActor
public protocol InputKeyboardHandlable: AnyObject {
    
    var bottomOffset: CGFloat { get }
    var movingContentBottomConsttaint: NSLayoutConstraint? { get }
}


extension InputKeyboardHandlable where Self: BaseUIView {
    
    public var bottomOffset: CGFloat {
        return 0
    }
    
    public func bindKeyboardFrameChangesIfPossible() -> Disposable? {
        
        guard self.movingContentBottomConsttaint != nil else { return nil }
        
        let keyboardChanges = NotificationCenter.default.rx.keyboardFrameWillChanges
        return keyboardChanges
            .subscribe(onNext: { [weak self] changes in
                self?.handleKeyboardFrameChanges(changes)
            })
    }
    
    private func handleKeyboardFrameChanges(_ changes: KeyboardFrameChanges) {
    
        self.layer.removeAllAnimations()
        
        let newContraint = changes.type == .show ? changes.to.height : 0
        self.movingContentBottomConsttaint?.constant = -(newContraint - bottomOffset)
        UIView.animate(withDuration: changes.duration, animations: { [weak self] in
            self?.layoutIfNeeded()
        })
    }
}
