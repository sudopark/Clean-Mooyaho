//
//  EnterHoorayImageViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/06.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EnterHoorayImageViewModel

public protocol EnterHoorayImageViewModel: AnyObject {

    // interactor
    func selectImage()
    func goNextInputStage()
    func skipInput()
    func deselect()
    
    // presenter
    var deslectEnable: Observable<Bool> { get }
    var selectedImagePath: Observable<String?> { get }
    var goNextStepWithForm: Observable<NewHoorayForm> { get }
}


// MARK: - EnterHoorayImageViewModelImple

public final class EnterHoorayImageViewModelImple: EnterHoorayImageViewModel {
    
    private let form: NewHoorayForm
    private let imagePickPermissionCheckService: ImagePickPermissionCheckService
    private let fileHandleService: FileHandleService
    private let router: EnterHoorayImageRouting
    
    public init(form: NewHoorayForm,
                imagePickPermissionCheckService: ImagePickPermissionCheckService,
                fileHandleService: FileHandleService = FileManager.default,
                router: EnterHoorayImageRouting) {
        self.form = form
        self.imagePickPermissionCheckService = imagePickPermissionCheckService
        self.fileHandleService = fileHandleService
        self.router = router
        
        self.subjects.selectedImagePath.onNext(form.imagePath)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let selectedImagePath = BehaviorSubject<String?>(value: nil)
        let continueNext = PublishSubject<NewHoorayForm>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterHoorayImageViewModelImple Interactor

extension EnterHoorayImageViewModelImple {
    
    public func selectImage() {
        
        let handlePermissionAvailable: () -> Void = { [weak self] in
            self?.askPickingMode()
        }
        
        let handleError: (Error) -> Void = { [weak self] _ in
            self?.presentPermissionNeed()
        }
        
        self.imagePickPermissionCheckService.preparePermission(for: .readWrite)
            .subscribe(onSuccess: handlePermissionAvailable, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func goNextInputStage() {
        
        self.router.closeScene(animated: true) { [weak self] in
            guard let self = self else { return }
            let imagePath = try? self.subjects.selectedImagePath.value()
            self.form.imagePath = imagePath
            self.subjects.continueNext.onNext(self.form)
        }
    }
    
    public func skipInput() {
        self.router.closeScene(animated: true) { [weak self] in
            guard let self = self else { return }
            self.subjects.continueNext.onNext(self.form)
        }
    }
    
    public func deselect() {
        
        defer {
            self.subjects.selectedImagePath.onNext(nil)
        }
        guard let path = try? self.subjects.selectedImagePath.value() else { return }
        self.fileHandleService.deletFile(FilePath.raw(path))
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}


// MARK: - EnterHoorayImageViewModelImple Presenter

extension EnterHoorayImageViewModelImple {
    
    public var selectedImagePath: Observable<String?> {
        return self.subjects.selectedImagePath.distinctUntilChanged()
    }
    
    public var deslectEnable: Observable<Bool> {
        return self.subjects.selectedImagePath.map{ $0 != nil }
    }
    
    public var goNextStepWithForm: Observable<NewHoorayForm> {
        return self.subjects.continueNext.asObservable()
    }
}


extension EnterHoorayImageViewModelImple {
    
    private func presentPermissionNeed() {
        
        let openSetting: () -> Void = {
            logger.todoImplement()
        }
        
        guard let form = AlertBuilder.init(base: .init())
                .title("TBD")
                .message("access need")
                .customConfirmText("Move Setting")
                .confirmed(openSetting)
                .build() else { return }
        self.router.alertForConfirm(form)
    }
    
    private func askPickingMode() {
        
        typealias Action = ActionSheetForm.Action
        let form = ActionSheetForm(title: nil, message: "[TBD] choose mode")
        
        if let imagePath = try? self.subjects.selectedImagePath.value() {
            let editAction = Action.init(text: "Edit image") { [weak self] in
                self?.presentEditImageScene(imagePath)
            }
            form.append(editAction)
        }
        
        let cameraAction = Action.init(text: "Take a picture") { [weak self] in
            self?.presentImagePicker(true)
        }
        form.append(cameraAction)
        
        let libraryAction = Action.init(text: "Choose from gallery") { [weak self] in
            self?.presentImagePicker(false)
        }
        form.append(libraryAction)
        
        form.append(.init(text: "Cancel", isCancel: true))
        
        self.router.alertActionSheet(form)
    }
    
    private func presentImagePicker(_ isCamera: Bool) {
        
        guard let pickPresenter = self.router.presentImagePicker(isCamera: isCamera) else { return }
        
        let updateSelectedImage: (String) -> Void = { [weak self] path in
            self?.subjects.selectedImagePath.onNext(path)
        }
        
        pickPresenter
            .selectedImagePath
            .subscribe(onNext: updateSelectedImage)
            .disposed(by: self.disposeBag)
    }
    
    private func presentEditImageScene(_ path: String) {
        logger.todoImplement()
    }
}
