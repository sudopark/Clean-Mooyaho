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
    public var fileHandleService: FileHandleService = FileManager.default
    private let selectedImagePathSubject = PublishSubject<String>()
    private let pickingErrorSubject = PublishSubject<Error>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.print(level: .debug, "image picker did disappear -> end result stream")
        self.selectedImagePathSubject.onCompleted()
        self.pickingErrorSubject.onCompleted()
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
        let newFileName = "\(TimeStamp.now())_\(fileName)"
        let newFilePath = FilePath.temp(newFileName)
        
        func saveEditedImage(_ image: UIImage) -> Maybe<String> {
            guard let data = image.pngData() else { return .error(ApplicationErrors.invalid) }
            return self.fileHandleService.write(data: data, to: newFilePath).map{
                newFilePath.absolutePath
            }
        }
        
        func copyImage() -> Maybe<String> {
            return self.fileHandleService.copy(source: FilePath.raw(imageURL.path), to: newFilePath)
                .map{ newFilePath.absolutePath }
        }
        
        let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        let movedFilePath: Maybe<String> = editedImage.when(exists: saveEditedImage(_:), or: copyImage)
        
        movedFilePath
            .subscribe(onSuccess: { [weak self] path in
                self?.selectedImagePathSubject.onNext(path)
                self?.dismiss(animated: true, completion: nil)
            }, onError: { [weak self] error in
                self?.pickingErrorSubject.onNext(error)
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.dispobseBag)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
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
