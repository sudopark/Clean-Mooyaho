//
//  String+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit


extension String {
    
    
    public func drawText(size: CGSize, fontSize: CGFloat, scale: CGFloat) -> UIImage? {
        
        let outputImageSize = size
        let baseSize = self.boundingRect(with: CGSize(width: 2048, height: 2048),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: UIFont.systemFont(ofSize: size.height / 2)], context: nil).size
        let fontSize = outputImageSize.width / max(baseSize.width, baseSize.height) * (outputImageSize.width / 2)
        let font = UIFont.systemFont(ofSize: fontSize)
        let textSize = self.boundingRect(with: CGSize(width: outputImageSize.width, height: outputImageSize.height),
                                         options: .usesLineFragmentOrigin,
                                         attributes: [.font: font], context: nil).size

        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        style.lineBreakMode = NSLineBreakMode.byClipping

        let attr : [NSAttributedString.Key : Any] = [
            .font : font,
            .paragraphStyle: style,
            .backgroundColor: UIColor.clear
        ]

        UIGraphicsBeginImageContextWithOptions(outputImageSize, false, 0)
        self.draw(in: CGRect(x: (size.width - textSize.width) / 2,
                             y: (size.height - textSize.height) / 2,
                             width: textSize.width,
                             height: textSize.height),
                             withAttributes: attr)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        return image
    }
    
    public var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(with args: Any...) -> String {
        let format = self.localized
        return String(format: format, args)
    }
    
    public func with(attribute: [NSAttributedString.Key: Any]) -> NSAttributedString {
        return NSAttributedString(string: self, attributes: attribute)
    }
    
    public func substring(nsRange: NSRange) -> String {
        return (self as NSString).substring(with: nsRange)
    }
    
    public func encode() -> String {
        return self.data(using: .nonLossyASCII, allowLossyConversion: true)
            .flatMap{ String(data: $0, encoding: .utf8) } ?? self
    }
    
    public func emptyAsNil() -> String? {
        return self.isEmpty ? nil : self
    }
}


extension String {
    
    public func expectWidth(font: UIFont) -> CGFloat {
        let constraintSize = CGSize(width: CGFloat.greatestFiniteMagnitude,
                                    height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintSize,
                                            options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                            attributes: [.font: font],
                                            context: nil)
        return ceil(boundingBox.width)
    }
}
