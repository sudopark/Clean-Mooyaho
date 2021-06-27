//
//  UIColor+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/12.
//

import UIKit


extension UIColor {
    
    public static func from(hex: String) -> UIColor? {
        let r, g, b, a: CGFloat

        guard hex.hasPrefix("#") else { return nil }
        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        guard scanner.scanHexInt64(&hexNumber) else { return nil }
        
        switch hexColor.count {
        case 8:
            r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
            g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
            b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
            a = CGFloat(hexNumber & 0x000000ff) / 255
            return UIColor(red: r, green: g, blue: b, alpha: a)
            
        case 6:
            r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
            g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
            b = CGFloat(hexNumber & 0x0000ff) / 255
            a = CGFloat(1.0)
            return UIColor(red: r, green: g, blue: b, alpha: a)
         
        default: break
        }
        
        return nil
    }
}
