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
    
    func drawImage(_ source: ImageSource) {
        self.cancelDraw()
        
        switch source {
        case let .emoji(value):
            self.drawEmoji(value)
            
        case let .path(path):
            self.drawRemoteImage(path)
            
        case let .reference(path, _):
            self.drawRemoteImage(path)
            // TOOD: show reference or not
        }
    }
    
    func cancelDraw() {
        self.internalImageView.cancelDrawRemoteImage()
        self.internalImageView.image = nil
    }
    
    private func drawEmoji(_ value: String) {
        let size = self.frame.size
        let fontSize = size.width * 0.8
        let scale = UIScreen.main.scale
        self.internalImageView.image = value.drawText(size: size, fontSize: fontSize, scale: scale)
    }
    
    private func drawRemoteImage(_ path: String) {
        self.internalImageView.drawRemoteImage(path)
    }
}
