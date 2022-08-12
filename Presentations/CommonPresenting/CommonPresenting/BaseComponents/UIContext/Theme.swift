//
//  Theme.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/21.
//

import UIKit


public protocol ColorSet: Sendable {
    
    var accentColor: UIColor { get }
    var secondaryAccentColor: UIColor { get }
    
    var appBackground: UIColor { get }
    var appSecondBackground: UIColor { get }
    
    var title: UIColor { get }
    var secondaryTitle: UIColor { get }
    var descriptionText: UIColor { get }
    var hintText: UIColor { get }
    
    var defaultButtonOff: UIColor { get }
    var defaultButtonOn: UIColor { get }
    var defaultButtonDisabled: UIColor { get }
    
    var thumbnailBackground: UIColor { get }
}

extension ColorSet {
    
    public var text: UIColor { self.title }
    
    public var raw: UIColor.Type {
        return UIColor.self
    }
    
    public var lineColor: UIColor {
        return UIColor.tertiarySystemGroupedBackground
    }
    
//    public var darkLine
    
    public var buttonBlue: UIColor {
        return UIColor.systemBlue.withAlphaComponent(0.9)
    }
    
    public var blueGray: UIColor? {
        return UIColor.from(hex: "#455A64")
    }
}

public protocol FontSet: Sendable {
    
    func get(_ size: CGFloat, weight: UIFont.Weight?) -> UIFont
}


public protocol Theme: Sendable {
    
    var colors: ColorSet { get }
    var fonts: FontSet { get }
}


// default set

public struct DefaultColorSet: ColorSet {
    
    public var accentColor: UIColor { self.buttonBlue }
    
    public var secondaryAccentColor: UIColor { UIColor(red: 0/255, green: 171/255, blue: 142/255, alpha: 1.0) }
    
    public var appBackground: UIColor { .systemBackground }
    
    public var appSecondBackground: UIColor { .tertiarySystemGroupedBackground }
    
    public var title: UIColor { .label }
    
    public var secondaryTitle: UIColor { .secondaryLabel }
    
    public var descriptionText: UIColor { UIColor.systemGray }
    
    public var hintText: UIColor { .placeholderText }
    
    // buttons
    public var defaultButtonOn: UIColor { self.buttonBlue }
    public var defaultButtonOff: UIColor { UIColor.lightGray }
    public var defaultButtonDisabled: UIColor { self.defaultButtonOff.withAlphaComponent(0.5) }
    
    // thumbnails
    public var thumbnailBackground: UIColor { self.hintText }
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
