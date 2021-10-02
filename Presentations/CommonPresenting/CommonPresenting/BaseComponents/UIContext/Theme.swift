//
//  Theme.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


public protocol ColorSet {
    
    var accentColor: UIColor { get }
    
    var appBackground: UIColor { get }
    var appSecondBackground: UIColor { get }
    
    var title: UIColor { get }
    var secondaryTitle: UIColor { get }
    var descriptionText: UIColor { get }
    var hintText: UIColor { get }
}

extension ColorSet {
    
    public var text: UIColor { self.title }
    
    public var raw: UIColor.Type {
        return UIColor.self
    }
    
    public var lineColor: UIColor {
        return UIColor.systemGroupedBackground
    }
    
    public var buttonBlue: UIColor {
        return UIColor.systemBlue.withAlphaComponent(0.8)
    }
}

public protocol FontSet {
    
    func get(_ size: CGFloat, weight: UIFont.Weight?) -> UIFont
}


public protocol Theme {
    
    var colors: ColorSet { get }
    var fonts: FontSet { get }
}


// default set

public struct DefaultColorSet: ColorSet {
    
    public var accentColor: UIColor { .systemIndigo }
    
    public var appBackground: UIColor { .white }
    
    public var appSecondBackground: UIColor { .systemGroupedBackground }
    
    public var title: UIColor { .black }
    
    public var secondaryTitle: UIColor { UIColor.darkGray }
    
    public var descriptionText: UIColor { UIColor.systemGray }
    
    public var hintText: UIColor { UIColor.lightGray }
}

public struct SystemFontSet: FontSet {
    
    public func get(_ size: CGFloat, weight: UIFont.Weight?) -> UIFont {
        return weight.flatMap { UIFont.systemFont(ofSize: size, weight: $0) }
            ?? UIFont.systemFont(ofSize: size)
    }
}

public struct DefaultTheme: Theme {
    
    public let colors: ColorSet = DefaultColorSet()
    public let fonts: FontSet = SystemFontSet()
    
    public init() {}
}
