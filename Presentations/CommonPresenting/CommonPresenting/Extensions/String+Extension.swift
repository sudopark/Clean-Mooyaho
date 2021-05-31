//
//  String+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit


extension String {
    
    
    public func drawText(size: CGSize, fontSize: CGFloat, scale: CGFloat) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        UIColor.white.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
