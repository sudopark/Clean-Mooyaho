//
//  Resources.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import Foundation


public struct UIContext {
    
    private let theme: Theme
    public init(theme: Theme) {
        self.theme = theme
    }
    
    fileprivate static var currentContext: UIContext = UIContext(theme: DefaultTheme())
    
    public static func register(_ context: UIContext) {
        self.currentContext = context
    }
}


extension UIContext {
    
    public var colors: ColorSet {
        return self.theme.colors
    }
    
    public var fonts: FontSet {
        return self.theme.fonts
    }
}


public protocol UIContextAccessable {
    
    var context: UIContext { get }
}

extension UIContextAccessable {
    
    public var context: UIContext {
        return UIContext.currentContext
    }
}
