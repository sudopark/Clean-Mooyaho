//
//  Theme.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


public protocol ColorSet {
    
    var appBackground: UIColor { get }
    
    var appSecondBackground: UIColor { get }
    
    var text: UIColor { get }
}

extension ColorSet {
    
    public var raw: UIColor.Type {
        return UIColor.self
    }
    
    public var lineColor: UIColor {
        return UIColor.systemGroupedBackground
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
    
    public var appBackground: UIColor { .white }
    
    public var appSecondBackground: UIColor { .systemGroupedBackground }
    
    public var text: UIColor { .black }
}

public struct DefaultFontSet: FontSet {
    
    public func get(_ size: CGFloat, weight: UIFont.Weight?) -> UIFont {
        return weight.flatMap { UIFont.systemFont(ofSize: size, weight: $0) }
            ?? UIFont.systemFont(ofSize: size)
    }
}

public struct DefaultTheme: Theme {
    
    public let colors: ColorSet = DefaultColorSet()
    public let fonts: FontSet = DefaultFontSet()
    
    public init() {}
}
