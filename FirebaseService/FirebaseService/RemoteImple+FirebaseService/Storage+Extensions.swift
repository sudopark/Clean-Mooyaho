//
//  Storage+Extensions.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/06/02.
//

import Foundation

import RxSwift

import DataStore


// MARK: - FirebaseStorageFileTree

enum FirebaseStorageFileTree {
    
    enum Images {
        case memberPfoile(_ name: String)
    }
    case images(Images)
}


// MARK: - FirebaseStorageFileTree SubTree and Path

extension FirebaseStorageFileTree.Images {
    
    var path: String {
        switch self {
        case let .memberPfoile(fileName): return "user_profiles/\(fileName)"
        }
    }
}

extension FirebaseStorageFileTree {
    
    var path: String {
        switch self {
        case let .images(subFolder): return "images/\(subFolder.path)"
        }
    }
}


extension Storage {
    
    func ref(for file: FirebaseStorageFileTree) -> StorageReference {
        let storageRef = self.reference()
        return storageRef.child(file.path)
    }
}



// MARK: - Upload File

enum FirebaseFileUploadEvents {
    case uploading(_ percent: Double)
    case completed(_ url: URL)
}

extension StorageReference {
    
    func uploadData(_ data: Data) -> Observable<FirebaseFileUploadEvents> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            var uploadTask: StorageUploadTask?
            uploadTask = self.putData(data, metadata: nil) { [weak self] metaData, error in
                guard let self = self else { return }
                guard error == nil, let _ = metaData else {
                    observer.onError(RemoteErrors.fileUploadFail(error))
                    return
                }
                
                self.downloadURL { url, error in
                    guard error == nil, let url = url else {
                        observer.onError(RemoteErrors.fileUploadFail(error))
                        return
                    }
                    
                    observer.onNext(.completed(url))
                }
            }
            
            uploadTask?.observe(.progress) { snapshot in
                guard let percent = snapshot.progress?.percentCompleted else { return }
                observer.onNext(.uploading(percent))
            }
            
            return Disposables.create {
                uploadTask?.removeAllObservers()
                uploadTask?.cancel()
            }
        }
    }
    
    func uploadLocalFile(_ filePath: String) -> Observable<FirebaseFileUploadEvents> {
        
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            let fileURL = URL(fileURLWithPath: filePath)
            
            var uploadTask: StorageUploadTask?
            uploadTask = self.putFile(from: fileURL, metadata: nil) { [weak self] metaData, error in
                guard let self = self else { return }
                guard error == nil, let _ = metaData else {
                    observer.onError(RemoteErrors.fileUploadFail(error))
                    return
                }
                
                self.downloadURL { url, error in
                    guard error == nil, let url = url else {
                        observer.onError(RemoteErrors.fileUploadFail(error))
                        return
                    }
                    
                    observer.onNext(.completed(url))
                }
            }
            
            return Disposables.create {
                uploadTask?.removeAllObservers()
                uploadTask?.cancel()
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
