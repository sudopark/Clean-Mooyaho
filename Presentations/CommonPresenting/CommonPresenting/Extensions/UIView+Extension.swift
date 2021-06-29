//
//  UIView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/30.
//

import UIKit


extension UIView {
    
    public func decorate<S: UIView>(_ decorating: (S) -> Void) {
        guard let subTypeView = self as? S else { return }
        decorating(subTypeView)
    }
}
