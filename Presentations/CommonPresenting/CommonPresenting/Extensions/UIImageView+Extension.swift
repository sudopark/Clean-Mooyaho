//
//  UIImageView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import Kingfisher


extension UIImageView {
    
    
    public func setupThumbnail(_ source: String,
                               progress: ((Int64, Int64) -> Void)? = nil,
                               completed: ((Result<UIImage, Error>) -> Void)? = nil) {
        guard let url = URL(string: source) else {
            self.cancelSetupThumbnail()
            return
        }
        
        if url.absoluteString.hasPrefix("file://") {
            let provider = LocalFileImageDataProvider(fileURL: url)
            self.kf.setImage(with: provider) { result in
                let mapResult = result.map{ $0.image }.mapError{ error -> Error in error }
                completed?(mapResult)
            }
        } else {
            
            self.kf.setImage(with: url, progressBlock: progress) { result in
                let mapResult = result.map{ $0.image }.mapError{ error -> Error in error }
                completed?(mapResult)
            }
        }
    }
    
    public func cancelSetupThumbnail() {
        self.kf.cancelDownloadTask()
        let nilProvider: ImageDataProvider? = nil
        self.kf.setImage(with: nilProvider)
    }
}
