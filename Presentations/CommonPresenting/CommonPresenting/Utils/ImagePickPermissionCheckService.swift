//
//  ImagePickPermissionCheckService.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/06.
//

import Foundation
import UIKit
import Photos


import RxSwift


public enum ImagePickAccessLevel {
    case addOnly
    case readWrite
    
    @available(iOS 14, *)
    var phAccessLevel: PHAccessLevel {
        switch self {
        case .addOnly: return .addOnly
        case .readWrite: return .readWrite
        }
    }
}

public enum ImagePickerPermissionStatus {
    case avail
    case denied
    case requestNeed
    
    init(status: PHAuthorizationStatus) {
        switch status {
        case .authorized, .limited: self = .avail
        case .notDetermined: self = .requestNeed
        default: self = .denied
        }
    }
}

public protocol ImagePickPermissionCheckService {
    
    func checkHasPermission(for level: ImagePickAccessLevel) -> ImagePickerPermissionStatus
    
    func preparePermission(for level: ImagePickAccessLevel) -> Maybe<Void>
}

public struct ImagePickPermissionDenied: Error {
    public init() {}
}

extension ImagePickPermissionCheckService {
    
    public func checkHasPermission(for level: ImagePickAccessLevel) -> ImagePickerPermissionStatus {
        
        if #available(iOS 14, *) {
            let accessLevel = level.phAccessLevel
            let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)
            return ImagePickerPermissionStatus(status: status)
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            return ImagePickerPermissionStatus(status: status)
        }
    }
    
    public func preparePermission(for level: ImagePickAccessLevel) -> Maybe<Void> {
        
        let permissionStatus = self.checkHasPermission(for: level)
        switch permissionStatus {
        case .avail: return .just()
        case .requestNeed: return self.requestPermission(for: level)
        case .denied: return .error(ImagePickPermissionDenied())
        }
    }
    
    private func requestPermission(for level: ImagePickAccessLevel) -> Maybe<Void> {
        
        return Maybe.create { callback in
            let handleRequestResult: (PHAuthorizationStatus) -> Void = { newStatus in
                let result = ImagePickerPermissionStatus(status: newStatus)
                if result == .avail {
                    callback(.success(()))
                } else {
                    callback(.error(ImagePickPermissionDenied()))
                }
            }
            if #available(iOS 14, *) {
                let accessLevel = level.phAccessLevel
                PHPhotoLibrary.requestAuthorization(for: accessLevel, handler: handleRequestResult)
            } else {
                PHPhotoLibrary.requestAuthorization(handleRequestResult)
            }
            return  Disposables.create()
        }
    }
}


public final class ImagePickPermissionCheckServiceImple: ImagePickPermissionCheckService {
    
    public init() {}
}
