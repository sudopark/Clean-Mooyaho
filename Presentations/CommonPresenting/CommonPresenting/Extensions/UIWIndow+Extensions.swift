//
//  UIWIndow+Extensions.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import UIKit


extension UIWindow {
    
    public static func safeAreaBottomInset() -> CGFloat {
        let window = UIApplication.shared.windows.first
        return window?.safeAreaInsets.bottom ?? 0
    }
}

