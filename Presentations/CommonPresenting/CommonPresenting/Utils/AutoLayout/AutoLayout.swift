//
//  AutoLayout.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


public struct AutoLayout {
    
    private let wrappedView: UIView
    public init(view: UIView) {
        self.wrappedView = view
    }
}


extension UIView {
    
    public var autoLayout: AutoLayout {
        return AutoLayout(view: self)
    }
}


@resultBuilder
public struct AutoLayoutBuilder {

    public static func buildBlock(_ components: (NSLayoutConstraint)...) -> [NSLayoutConstraint] {
        
        return components
    }
}


extension AutoLayout {
    
    public func make(@AutoLayoutBuilder _ builder: (UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        if self.wrappedView.translatesAutoresizingMaskIntoConstraints != false {
            self.wrappedView.translatesAutoresizingMaskIntoConstraints = false
        }
        return builder(self.wrappedView)
    }
    
    @discardableResult
    public func active(@AutoLayoutBuilder _ builder: (UIView) -> [NSLayoutConstraint]) -> AutoLayout {
        if self.wrappedView.translatesAutoresizingMaskIntoConstraints != false {
            self.wrappedView.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraints = builder(self.wrappedView)
        NSLayoutConstraint.activate(constraints)
        return self
    }
    
    public func make(with otherView: UIView, @AutoLayoutBuilder _ builder: (UIView, UIView) -> [NSLayoutConstraint]) -> [NSLayoutConstraint] {
        if self.wrappedView.translatesAutoresizingMaskIntoConstraints != false {
            self.wrappedView.translatesAutoresizingMaskIntoConstraints = false
        }
        if otherView.translatesAutoresizingMaskIntoConstraints != false {
            otherView.translatesAutoresizingMaskIntoConstraints = false
        }
        return builder(self.wrappedView, otherView)
    }
    
    @discardableResult
    public func active(with otherView: UIView, @AutoLayoutBuilder _ builder: (UIView, UIView) -> [NSLayoutConstraint]) -> AutoLayout {
        if self.wrappedView.translatesAutoresizingMaskIntoConstraints != false {
            self.wrappedView.translatesAutoresizingMaskIntoConstraints = false
        }
        if otherView.translatesAutoresizingMaskIntoConstraints != false {
            otherView.translatesAutoresizingMaskIntoConstraints = false
        }
        let constraints = builder(self.wrappedView, otherView)
        NSLayoutConstraint.activate(constraints)
        return self
    }
}
