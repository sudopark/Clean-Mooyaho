//
//  FirebaseFileStorageImple.swift
//  MooyahoApp
//
//  Created by sudo.park on 2022/07/19.
//  Copyright © 2022 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Remote
import FirebaseStorage
import Extensions


final class FirebaseFileStorageImple: RemoteFileStorage {
    
    private let storge: Storage
    init(storge: Storage) {
        self.storge = storge
    }
 
    private func fileReference(_ path: String) -> StorageReference {
        return storge.reference().child(path)
    }
}


extension FirebaseFileStorageImple {
    
    func upload(_ path: String, data: Data) -> Observable<FileUploadEvent> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            var uploadTask: StorageUploadTask?
            let ref = self.fileReference(path)
            uploadTask = ref.putData(data, metadata: nil) { meta, error in
                guard error == nil, meta != nil else {
                    observer.onError(error ?? RuntimeError("fail to upload file to path: \(path)"))
                    return
                }
                ref.downloadURL { url, error in
                    guard error == nil, let url = url else {
                        observer.onError(error ?? RuntimeError("fail fetch to uploaded file url, file path: \(path)"))
                        return
                    }
                    
                    observer.onNext(.completed(url))
                }
                
            }
            
            uploadTask?.observe(.progress) { snapshot in
                guard let percent = snapshot.progress?.percentCompleted else { return }
                observer.onNext(.uploading(percent))
            }
            
            uploadTask?.resume()
            
            
            return Disposables.create {
                uploadTask?.removeAllObservers()
                uploadTask?.cancel()
            }
        }
    }
    
    func upload(_ path: String, filePath: String) -> Observable<FileUploadEvent> {
        
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            let fileURL = URL(fileURLWithPath: filePath)
            var uploadTask: StorageUploadTask?
            let ref = self.fileReference(path)
            uploadTask = ref.putFile(from: fileURL, metadata: nil) { meta, error in
                guard error == nil, meta != nil else {
                    observer.onError(error ?? RuntimeError("fail to upload file from file path: \(path)"))
                    return
                }
                
                ref.downloadURL { url, error in
                    guard error == nil, let url = url else {
                        observer.onError(error ?? RuntimeError("fail fetch to uploaded file url, from file path: \(path)"))
                        return
                    }
                    
                    observer.onNext(.completed(url))
                }
                
                uploadTask?.observe(.progress) { snapshot in
                    guard let percent = snapshot.progress?.percentCompleted else { return }
                    observer.onNext(.uploading(percent))
                }
                
                uploadTask?.resume()
            }
            
            return Disposables.create {
                uploadTask?.cancel()
                uploadTask?.removeAllObservers()
            }
        }
    }
}


private extension Progress {
    
    var percentCompleted: Double? {
        guard self.totalUnitCount > 0 else { return nil }
        return 100.0 * Double(self.completedUnitCount) / Double(self.totalUnitCount)
    }
}
