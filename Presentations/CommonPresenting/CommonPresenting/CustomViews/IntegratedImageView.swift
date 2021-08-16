//
//  IntegratedImageView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import Domain

public class IntegratedImageView: UIView {
    
    let internalImageView = UIImageView()
    
    public var showReference = false
    
    public let descriptionView = UILabel()
    
    public func drawImage(_ image: UIImage, withCancel: Bool = true) {
        if withCancel {
            self.cancelSetupImage()
        }
        self.internalImageView.image = image
    }
    
    public func setupImage(using source: ImageSource, resize: CGSize? = nil) {
        self.cancelSetupImage()
        
        switch source {
        case let .emoji(value):
            self.drawEmoji(value, resize: resize)
            
        case let .path(path):
            self.setupRemoteImage(path, resize: resize)
            
        case let .reference(path, _):
            self.setupRemoteImage(path, resize: resize)
            // TOOD: show reference or not
        }
    }
    
    public func cancelSetupImage() {
        self.internalImageView.cancelSetupThumbnail()
        self.internalImageView.image = nil
    }
    
    private func drawEmoji(_ value: String, resize: CGSize? = nil) {
        let size = resize ?? self.frame.size
        let fontSize = size.width * 0.75
        let scale = UIScreen.main.scale
        self.internalImageView.image = value.drawText(size: size, fontSize: fontSize, scale: scale)
    }
    
    private func setupRemoteImage(_ path: String, resize: CGSize? = nil) {
        self.internalImageView.setupThumbnail(path, resize: resize)
    }
}


extension IntegratedImageView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(internalImageView)
        internalImageView.autoLayout.fill(self)
    }
    
    public func setupStyling() {
        self.backgroundColor = .clear
        self.internalImageView.backgroundColor = .clear
        self.internalImageView.contentMode = .scaleAspectFill
    }
}
