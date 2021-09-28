//
//  Resources.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit

import RxSwift


public struct UIContext {
    
    private let theme: Theme
    private static let appStatus = BehaviorSubject<ApplicationStatus>(value: .idle)
    public init(theme: Theme) {
        self.theme = theme
    }
    
    static var currentContext: UIContext = UIContext(theme: DefaultTheme())
    
    public static func register(_ context: UIContext) {
        self.currentContext = context
    }
    
    public static func updateApp(status: ApplicationStatus) {
        self.appStatus.onNext(status)
    }
    
    public static var currentAppStatus: Observable<ApplicationStatus> {
        return self.appStatus.distinctUntilChanged()
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
    
    var uiContext: UIContext { get }
}

extension UIContextAccessable {
    
    public var uiContext: UIContext {
        return UIContext.currentContext
    }
}
