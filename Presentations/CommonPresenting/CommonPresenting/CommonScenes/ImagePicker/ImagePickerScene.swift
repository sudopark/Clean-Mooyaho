//
//  ImagePickerScene.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import Photos

import RxSwift
import RxCocoa

import Domain


// MARK: - ImagePickerScene Interactor & Presenter

//public protocol ImagePickerSceneInteractor { }
//
public protocol ImagePickerScenePresenter {
    
    var selectedImagePath: Observable<String> { get }
    var selectImageError: Observable<Error> { get }
}


// MARK: - ImagePickerScene

public protocol ImagePickerScene: Scenable {
    
//    var interactor: ImagePickerSceneInteractor? { get }
//
    var presenter: ImagePickerScenePresenter { get }
}


// MARK: - UIImagePicker conform ImagePickerScene

public final class SimpleImagePickerViewController: UIImagePickerController {
    
    private let dispobseBag = DisposeBag()
    private let fileHandleService: FileHandleService
    private let selectedImagePathSubject = PublishSubject<String>()
    private let pickingErrorSubject = PublishSubject<Error>()
    
    public init(isCamera: Bool,
                fileHandleService: FileHandleService = FileManager.default) {
        
        self.fileHandleService = fileHandleService
        super.init(nibName: nil, bundle: nil)
        if isCamera {
            self.sourceType = .camera
        } else {
            self.sourceType = .photoLibrary
        }
        self.allowsEditing = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

extension SimpleImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [InfoKey : Any]) {
        
        
        guard let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL else {
            self.pickingErrorSubject.onNext(ApplicationErrors.invalid)
            return
        }
        
        let fileName = imageURL.lastPathComponent
        let fileType = imageURL.pathExtension
        let newFileName = "\(TimeStamp.now())_\(fileName).\(fileType)"
        let newFilePath = FilePath.temp(newFileName)
        
        func saveEditedImage(_ image: UIImage) -> Maybe<String> {
            guard let data = image.pngData() else { return .error(ApplicationErrors.invalid) }
            return self.fileHandleService.write(data: data, to: newFilePath).map{
                newFilePath.fullPath
            }
        }
        
        func copyImage() -> Maybe<String> {
            return self.fileHandleService.copy(source: FilePath.raw(imageURL.path), to: newFilePath)
                .map{ newFilePath.fullPath }
        }
        
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let movedFilePath: Maybe<String> = editedImage.when(exists: saveEditedImage(_:), or: copyImage)
        
        movedFilePath
            .subscribe(onSuccess: { [weak self] path in
                self?.dismiss(animated: true) { [weak self] in
                    self?.selectedImagePathSubject.onNext(path)
                }
            }, onError: { [weak self] error in
                self?.pickingErrorSubject.onNext(error)
            })
            .disposed(by: self.dispobseBag)
    }
}

extension SimpleImagePickerViewController: ImagePickerScenePresenter {
    
    
    public var selectedImagePath: Observable<String> {
        return self.selectedImagePathSubject.asObservable()
    }
    
    public var selectImageError: Observable<Error> {
        return self.pickingErrorSubject.asObservable()
    }
}


extension SimpleImagePickerViewController: ImagePickerScene {
    
    public var presenter: ImagePickerScenePresenter {
        return self
    }
}
