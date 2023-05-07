//
//  MockRemoteFileStorage.swift
//  RemoteDoubles
//
//  Created by sudo.park on 2022/07/30.
//

import Foundation

import Remote
import RxSwift



open class MockRemoteFileStorage: RemoteFileStorage {
    
    public init() { } 

    public var uploadByDataEvents = PublishSubject<FileUploadEvent>()
    open func upload(_ path: String, data: Data) -> Observable<FileUploadEvent> {
        return self.uploadByDataEvents.asObservable()
    }
    
    public var uploadByPathEvents = PublishSubject<FileUploadEvent>()
    open func upload(_ path: String, filePath: String) -> Observable<FileUploadEvent> {
        return self.uploadByPathEvents.asObservable()
    }
}
