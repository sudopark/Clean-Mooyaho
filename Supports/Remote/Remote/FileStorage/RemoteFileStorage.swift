//
//  RemoteFileStorage.swift
//  Remote
//
//  Created by sudo.park on 2022/07/16.
//

import Foundation

import RxSwift


public enum FileUploadEvent {
    case uploading(_ percent: Double)
    case completed(_ url: URL)
}


public protocol RemoteFileStorage {
    
    func upload(_ path: String, data: Data) -> Observable<FileUploadEvent>
    func upload(_ path: String, filePath: String) -> Observable<FileUploadEvent>
}
