//
//  IntegratedImageView.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import Domain

public class IntegratedImageView: BaseUIView {
    
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
        self.setupImage(using: .imageSource(source), resize: resize)
    }
    
    public func setupImage(using thumbnail: Thumbnail, resize: CGSize? = nil) {
        self.cancelSetupImage()
        
        switch thumbnail {
        case let .emoji(value):
            self.drawEmoji(value, resize: resize)
            
        case let .imageSource(source):
            self.setupRemoteImage(source, resize: resize)
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
    
    private func setupRemoteImage(_ source: ImageSource, resize: CGSize? = nil) {
        self.internalImageView.setupThumbnail(source, resize: resize)
    }
}


extension IntegratedImageView: Presenting {
    
    public func setupLayout() {
        
        self.addSubview(internalImageView)
        internalImageView.autoLayout.fill(self)
    }
    
    public func setupStyling() {
        self.backgroundColor = self.uiContext.colors.thumbnailBackground
        self.internalImageView.backgroundColor = .clear
        self.internalImageView.contentMode = .scaleAspectFill
    }
}


// MARK: - SwiftUI version - IntegratedImageView

import SwiftUI

extension Views {
    
    
    public struct IntegratedImageView: View {
        
        @Binding private var thumbnail: Thumbnail?
        private let resize: CGSize?
        private let backgroundColor: Color?
        
        public init(_ thumbnail: Binding<Thumbnail?>,
                    resize: CGSize? = nil,
                    backgroundColor: Color? = nil) {
            self._thumbnail = thumbnail
            self.resize = resize
            self.backgroundColor = backgroundColor
        }
        
        public var body: some View {
            ZStack {
                self.backgroundColor ?? self.uiContext.colors.thumbnailBackground.asColor
                contentView(by: self.thumbnail)
            }
        }
        
        private func contentView(by thumbnail: Thumbnail?) -> some View {
            switch thumbnail {
            case .imageSource(let imageSource):
                return self.remoteImage(imageSource, resize: self.resize)
                    .asAny()
                 
            case .emoji(let value):
                return self.emoji(value)
                    .asAny()
                
            case .none:
                return EmptyView()
                    .asAny()
            }
        }
        
        private func emoji(_ value: String) -> some View {
            GeometryReader { geometry in
                Text(value)
                    .font(
                        self.theme.fonts.get(geometry.size.width * 0.75, weight: .regular).asFont
                    )
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        
        private func remoteImage(_ source: ImageSource, resize: CGSize?) -> some View {
            ZStack {
                Views.RemoteImage(.constant(source), resize: resize)
                    .resize()
            }
        }
    }
}


struct IntegratedImageView_Preview: PreviewProvider {

    static var previews: some View {

        let thumbnail: Thumbnail = .imageSource(.init(path: "https://miro.medium.com/max/1400/1*y5nsXq1oeXf8RtGdM5eCaQ.jpeg", size: .init(100, 100)))
//        let thumbnail: Thumbnail = .emoji("🤑")
        return Views.IntegratedImageView(.constant(thumbnail), resize: nil)
            .previewLayout(.fixed(width: 200, height: 200))
            .clipShape(Circle())
    }
}
