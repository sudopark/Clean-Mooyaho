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
public protocol ImagePickerSceneListenable: AnyObject {
    
    func imagePicker(didSelect imagePath: String, imageSize: ImageSize)
    func imagePicker(didFail selectError: Error)
}


// MARK: - ImagePickerScene

public protocol ImagePickerScene: Scenable {
    
}


// MARK: - UIImagePicker conform ImagePickerScene

public final class SimpleImagePickerViewController: UIImagePickerController {
    
    private let dispobseBag = DisposeBag()
    public var fileHandleService: FileHandleService = FileManager.default
    public weak var listener: ImagePickerSceneListenable?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logger.print(level: .debug, "image picker did disappear -> end result stream")
    }
}

extension SimpleImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [InfoKey : Any]) {
        
        
        guard let imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL,
              let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
                  ?? info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        else {
            self.listener?.imagePicker(didFail: ApplicationErrors.invalid)
            return
        }
        let imageSize = ImageSize(image.size.width, image.size.height)
        
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
                self?.dismissAndReturn(result: .success((path, imageSize)))
            }, onError: { [weak self] error in
                self?.dismissAndReturn(result: .failure(error))
            })
            .disposed(by: self.dispobseBag)
    }
    
    private func dismissAndReturn(result: Result<(String, ImageSize), Error>) {
        self.dismiss(animated: true) { [weak self] in
            switch result {
            case let .success(info):
                self?.listener?.imagePicker(didSelect: info.0, imageSize: info.1)
                
            case let .failure(error):
                self?.listener?.imagePicker(didFail: error)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}


extension SimpleImagePickerViewController: ImagePickerScene { }
