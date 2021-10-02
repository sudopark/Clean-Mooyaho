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
    
    @available(*, deprecated, message: "use other decorating")
    @discardableResult
    public static func title(_ label: UILabel) -> UILabel {
        return label
            |> \.font .~ self.uiContext.fonts.get(18, weight: .bold)
            |> \.textColor .~ self.uiContext.colors.title
    }
}