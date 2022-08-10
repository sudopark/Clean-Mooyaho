//
//  ImageResizeService.swift
//  Domain
//
//  Created by sudo.park on 2021/12/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import RxSwift
import Prelude
import Optics


public protocol ImageResizeService: Sendable {
    
    func resize(_ image: UIImage) -> Maybe<UIImage>
}


public final class ImageResizeServiceImple: ImageResizeService {
    
    private let maxSize: CGFloat = 480
    
    public init() { }
}


extension ImageResizeServiceImple {
    
    public func resize(_ image: UIImage) -> Maybe<UIImage> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            let newSize = self.calculateNewSize(image.size)
            let newImage = image.resizing(upto: newSize)
            callback(.success(newImage))
            return Disposables.create()
        }
    }
    
    private func calculateNewSize(_ size: CGSize) -> CGSize {
        
        if size.width > self.maxSize {
            return self.calculateNewSize <| size.reduceWidth(upto: self.maxSize)
        }
        
        if size.height > self.maxSize {
            return self.calculateNewSize <| size.reduceHeight(upto: self.maxSize)
        }
        
        return size
    }
}


private extension CGSize {
    
    func reduceWidth(upto: CGFloat) -> CGSize {
        let multiply = upto / self.width
        return CGSize(width: upto, height: self.height * multiply)
    }
    
    func reduceHeight(upto: CGFloat) -> CGSize {
        let multiply = upto / self.height
        return CGSize(width: self.width * multiply, height: upto)
    }
}

private extension UIImage {
    
    func resizing(upto: CGSize) -> UIImage {
        guard upto != self.size else { return self }
        let rect = CGRect(x: 0, y: 0, width: upto.width, height: upto.height)
        UIGraphicsBeginImageContextWithOptions(upto, false, self.scale)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage ?? self
    }
}
