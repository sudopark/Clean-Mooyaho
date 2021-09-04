//
//  UIImageView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import Kingfisher

import Domain


extension UIImageView {
    
    private func resizeTargetSize(_ requestedSize: CGSize?) -> CGSize {
        let scale = UIScreen.main.scale
        let size = requestedSize ?? self.bounds.size
        return CGSize(width: size.width * scale, height: size.height * scale)
    }
    
    public func setupThumbnail(_ path: String,
                               resize: CGSize? = nil,
                               progress: ((Int64, Int64) -> Void)? = nil,
                               completed: ((Result<UIImage, Error>) -> Void)? = nil) {
        
        self.setupThumbnail(.init(path: path, size: nil),
                            resize: resize,
                            progress: progress,
                            completed: completed)
    }
    
    public func setupThumbnail(_ source: ImageSource,
                               resize: CGSize? = nil,
                               progress: ((Int64, Int64) -> Void)? = nil,
                               completed: ((Result<UIImage, Error>) -> Void)? = nil) {
        guard let url = URL(string: source.path) else {
            self.cancelSetupThumbnail()
            return
        }
        
        let targetSize = self.resizeTargetSize(resize)
        let processor = DownsamplingImageProcessor(size: targetSize)
        
        if url.absoluteString.hasPrefix("file://") {
            let provider = LocalFileImageDataProvider(fileURL: url)
            self.kf.setImage(with: provider, options: [.processor(processor)]) { result in
                let mapResult = result.map{ $0.image }.mapError{ error -> Error in error }
                completed?(mapResult)
            }
        } else {
            
            self.kf.setImage(with: url, options: [.processor(processor)], progressBlock: progress) { result in
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
