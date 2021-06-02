//
//  UIImageView+Extension.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/05/31.
//

import UIKit

import Kingfisher


extension UIImageView {
    
    
    func setupRemoteImage(_ source: String,
                         progress: ((Int64, Int64) -> Void)? = nil,
                         completed: ((Result<UIImage, Error>) -> Void)? = nil) {
        let url = URL(string: source)
        self.kf.setImage(with: url, progressBlock: progress) { result in
            let mapResult = result.map{ $0.image }.mapError{ error -> Error in error }
            completed?(mapResult)
        }
    }
    
    func cancelSetupRemoteImage() {
        self.kf.cancelDownloadTask()
        let nilProvider: ImageDataProvider? = nil
        self.kf.setImage(with: nilProvider)
    }
}

