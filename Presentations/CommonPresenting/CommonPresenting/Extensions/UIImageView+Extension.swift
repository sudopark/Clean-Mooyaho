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


// MARK: SwiftUI -  RemoteImage

import SwiftUI

extension Views {
    
    
    public struct RemoteImage: View {
        
        @Binding var imageSource: ImageSource
        private let resize: CGSize?
        
        public init(_ imageSource: Binding<ImageSource>, resize: CGSize? = nil) {
            self._imageSource = imageSource
            self.resize = resize
        }
        
        public var configurations: [(KFImage) -> KFImage] = []
        
        public var body: some View {
            Group {
                self.configurations
                    .reduce(
                        self.initialImage()
                    ) { current, configue in
                        configue(current)
                    }
                    .downSamplingIfNeed(self.resize)
                    .cancelOnDisappear(true)
                    .cacheOriginalImage()
            }
        }
        
        private func initialImage() -> KFImage {
            if self.imageSource.path.hasPrefix("file://"),
               let fileURL = URL(string: self.imageSource.path) {
                let provider = LocalFileImageDataProvider(fileURL: fileURL)
                return KFImage(source: .provider(provider))
            } else {
                return KFImage(self.imageSource.path)
            }
        }
    }
}

extension Views.RemoteImage {
    
    public func resize(capInsets: EdgeInsets = EdgeInsets(),
                       resizingMode: Image.ResizingMode = .stretch) -> Views.RemoteImage {
        
        let block: (KFImage) -> KFImage = { $0.resizable(capInsets: capInsets, resizingMode: resizingMode) }
        return self.configue(with: block)
    }
    
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode) -> Views.RemoteImage {
        let block: (KFImage) -> KFImage = { $0.renderingMode(renderingMode) }
        return self.configue(with: block)
    }
    
    public func interpolation(_ interpolation: Image.Interpolation) -> Views.RemoteImage {
        let block: (KFImage) -> KFImage = { $0.interpolation(interpolation) }
        return self.configue(with: block)
    }
    
    public func antialiased(_ isAntialiased: Bool) -> Views.RemoteImage {
        let block: (KFImage) -> KFImage = { $0.antialiased(isAntialiased) }
        return self.configue(with: block)
    }
    
    private func configue(with block: @escaping (KFImage) -> KFImage) -> Views.RemoteImage {
        var sender = self
        sender.configurations = self.configurations + [block]
        return sender
    }
}


private extension KFImage {
    
    init(_ path: String) {
        self.init(URL(string: path))
    }
    
    func downSamplingIfNeed(_ resize: CGSize?) -> KFImage {
        guard let resize = resize else { return self }
        let scale = UIScreen.main.scale
        return self
            .downsampling(
                size: .init(width: resize.width * scale,
                            height: resize.height * scale)
            )
    }
}
