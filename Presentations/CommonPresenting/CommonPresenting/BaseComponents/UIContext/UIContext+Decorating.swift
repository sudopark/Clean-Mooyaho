//
//  UIContext+Decorating.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/29.
//

import UIKit

import Prelude
import Optics

extension UIContext {
    
    public enum Decorating {
        
        static var uiContext: UIContext { UIContext.currentContext }
    }

    public var decorating: Decorating.Type {
        return Decorating.self
    }
}


// MARK: - decorating labels

extension UIContext.Decorating {
    
    @discardableResult
    public static func header(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(22, weight: .heavy)
            |> \.textColor .~ self.uiContext.colors.title
            |> \.numberOfLines .~ 1
    }
    
    @discardableResult
    public static func smallHeader(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(18, weight: .bold)
            |> \.textColor .~ self.uiContext.colors.title
            |> \.numberOfLines .~ 1
    }
    
    
    @discardableResult
    public static func listSectionTitle(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(13, weight: .bold)
            |> \.textColor .~ self.uiContext.colors.secondaryTitle
            |> \.numberOfLines .~ 1
    }
    
    @discardableResult
    public static func listItemTitle(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(15, weight: .medium)
            |> \.textColor .~ self.uiContext.colors.title
    }
    
    @discardableResult
    public static func listItemDescription(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(12, weight: .medium)
            |> \.textColor .~ self.uiContext.colors.descriptionText
    }
    
    @discardableResult
    public static func listItemSubDescription(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(11, weight: .medium)
            |> \.textColor .~ self.uiContext.colors.descriptionText
    }
    
    @discardableResult
    public static func listItemAccentText(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(12, weight: .medium)
            |> \.textColor .~ UIColor.systemBlue
    }
    
    @discardableResult
    public static func placeHolder(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(14, weight: .regular)
            |> \.textColor .~ self.uiContext.colors.hintText
    }
    
    @discardableResult
    public static func underLineText(_ label: UILabel) -> UILabel {
        guard let text = label.text else { return label }
        let attr: [NSAttributedString.Key: Any] = [
            .underlineStyle : NSUnderlineStyle.single
        ]
        let attributed = NSAttributedString(string: text, attributes: attr)
        return label
            |> \.attributedText .~ attributed
    }
    
    @discardableResult
    public static func roundedThumbnail(_ uiImageView: UIImageView,
                                        radius: CGFloat) -> UIImageView {
        return uiImageView
            |> \.contentMode .~ .scaleAspectFill
            |> \.layer.borderWidth .~ 1.0
            |> \.layer.borderColor .~ (self.uiContext.colors.lineColor.cgColor as CGColor?)
            |> \.backgroundColor .~ (self.uiContext.colors.lineColor as UIColor?)
            |> \.layer.cornerRadius .~ radius
            |> \.clipsToBounds .~ true
    }
    
    @discardableResult
    public static func title(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(18, weight: .bold)
            |> \.textColor .~ self.uiContext.colors.title
    }
}


// MARK: - SwiftUI + Decorating

import SwiftUI

public extension Text {
    
    func header() -> some View {
        return self
            .font(self.uiContext.fonts.get(22, weight: .heavy).asFont)
            .foregroundColor(self.uiContext.colors.title.asColor)
            .lineLimit(1)
    }
    
    func smallHeader() -> some View {
        return self
            .font(self.uiContext.fonts.get(18, weight: .bold).asFont)
            .foregroundColor(self.uiContext.colors.title.asColor)
            .lineLimit(1)
    }
    
    func listSectionTitle() -> some View {
        return self
            .font(self.uiContext.fonts.get(13, weight: .bold).asFont)
            .foregroundColor(self.uiContext.colors.secondaryTitle.asColor)
            .lineLimit(1)
    }
    
    func listItemTitle() -> some View {
        return self
            .font(self.uiContext.fonts.get(15, weight: .medium).asFont)
            .foregroundColor(self.uiContext.colors.title.asColor)
    }
    
    func listItemDescription() -> some View {
        return self
            .font(self.uiContext.fonts.get(12, weight: .medium).asFont)
            .foregroundColor(self.uiContext.colors.descriptionText.asColor)
    }
    
    func listItemSubDescription() -> some View {
        return self
            .font(self.uiContext.fonts.get(11, weight: .medium).asFont)
            .foregroundColor(self.uiContext.colors.descriptionText.asColor)
    }
    
    func listItemAccentText() -> some View {
        return self
            .font(self.uiContext.fonts.get(12, weight: .medium).asFont)
            .foregroundColor(self.uiContext.colors.accentColor.asColor)
    }
    
    func placeHolder() -> some View {
        return self
            .font(self.uiContext.fonts.get(14, weight: .regular).asFont)
            .foregroundColor(self.uiContext.colors.hintText.asColor)
    }
    
    func title() -> some View {
        return self
            .font(self.uiContext.fonts.get(18, weight: .bold).asFont)
            .foregroundColor(self.uiContext.colors.title.asColor)
    }
}



public extension UIFont {
    
    var asFont: Font {
        return Font(self as CTFont)
    }
}
