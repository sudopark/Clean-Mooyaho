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
import Extensions


// MARK: - ImagePickerScene Interactor & Presenter

//public protocol ImagePickerSceneInteractor { }
//
public protocol ImagePickerSceneListenable: Sendable, AnyObject {
    
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
    public var resizeService: ImageResizeService = ImageResizeServiceImple()
    
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
        let isEdited = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) != nil
        
        logger.print(level: .debug, "selected imageSize: \(image.megaSize()), size: \(image.size)")
        
        // resize image
        let resizeImage = self.resizeService.resize(image)
        let thenSaveToTempPath: (UIImage) -> Maybe<(String, ImageSize)> = { [weak self] resized in
            guard let self = self else { return .empty() }
            logger.print(level: .debug, "resized image => \(resized.megaSize()), size: \(resized.size)")
            return self.copyImageToTempPath(resized,
                                            imageURL: imageURL,
                                            isEdited: isEdited,
                                            fileName: imageURL.lastPathComponent)
        }
        let handlePicked: ((String, ImageSize)) -> Void = { [weak self] pair in
            self?.dismissAndReturn(result: .success(pair))
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.dismissAndReturn(result: .failure(error))
        }
        
        resizeImage
            .flatMap(thenSaveToTempPath)
            .subscribe(onSuccess: handlePicked,
                       onError: handleError)
            .disposed(by: self.dispobseBag)
    }
    
    private func copyImageToTempPath(_ image: UIImage,
                                     imageURL: URL,
                                     isEdited: Bool,
                                     fileName: String) -> Maybe<(String, ImageSize)> {
        let imageSize = ImageSize(image.size.width, image.size.height)
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
        
        let moveFile = isEdited ? saveEditedImage(image) : copyImage()
        return moveFile
            .map { ($0, imageSize) }
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


private extension UIImage {
    
    func megaSize() -> String {
        let byteCount = self.pngData()?.count ?? 0
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(byteCount))
    }
}
