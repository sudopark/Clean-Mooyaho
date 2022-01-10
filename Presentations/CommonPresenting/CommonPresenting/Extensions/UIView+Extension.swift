//
//  UIView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/30.
//

import UIKit


extension UIView {
    
    @available(*, deprecated, message: "use decorate<S: UIView>(_ decorating: (S) -> S)")
    public func decorate<S: UIView>(_ decorating: (S) -> Void) {
        guard let subTypeView = self as? S else { return }
        decorating(subTypeView)
    }
    
    public func decorate<S: UIView>(_ decorating: (S) -> S) {
        guard let subTypeView = self as? S else { return }
        _ = decorating(subTypeView)
    }
}


extension UIView {
    
    public func providerFeedbackImpact(with style: FeedbackImapctStyle) {
        let generator = UIImpactFeedbackGenerator(style: style.uiImpactStyle)
        generator.prepare()
        generator.impactOccurred()
    }
}
