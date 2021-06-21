//
//  MakeHoorayViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting

// MARK: - MakeHoorayViewModel

public protocol MakeHoorayViewModel: AnyObject {

    // interactor
    func showUp()
    func requestEnterImage()
    func requestEnterMessage()
    func requestEnterTags()
    func requestSelectPlace()
    func requestPublishNewHooray()
    
    // presenter
    var hoorayKeyword: Observable<String> { get }
    
    var selectedImagePath: Observable<String?> { get }
    var enteredMessage: Observable<String?> { get }
    var enteredTags: Observable<[String]> { get }
    var selectedPlaceName: Observable<String?> { get }
    
    var isPublishable: Observable<Bool> { get }
    var isPublishing: Observable<Bool> { get }
    var publishedNewHooray: Observable<Hooray> { get }
}


// MARK: - MakeHoorayViewModelImple

enum SelectPlace {
    case alreadyExist(_ placeID: String)
    case registerNeeds(_ newPlaceForm: NewPlaceForm)
}

public final class MakeHoorayViewModelImple: MakeHoorayViewModel {
    
    private let memberUsecase: MemberUsecase
    private let userLocationUsecase: UserLocationUsecase
    private let hoorayPublishUsecase: HoorayPublisherUsecase
    private let permissionService: ImagePickPermissionCheckService
    private let router: MakeHoorayRouting
    
    public init(memberUsecase: MemberUsecase,
                userLocationUsecase: UserLocationUsecase,
                hoorayPublishUsecase: HoorayPublisherUsecase,
                permissionService: ImagePickPermissionCheckService,
                router: MakeHoorayRouting) {
        self.memberUsecase = memberUsecase
        self.userLocationUsecase = userLocationUsecase
        self.hoorayPublishUsecase = hoorayPublishUsecase
        self.permissionService = permissionService
        self.router = router
    
        self.internalBind()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let currentMember = BehaviorRelay<Member?>(value: nil)
        let selectedHoorayKeyword = BehaviorRelay<String?>(value: nil)
        let pendingForm = BehaviorRelay<NewHoorayForm?>(value: nil)
        let isPublishing = BehaviorRelay<Bool>(value: false)
        let newHooray = PublishSubject<Hooray>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    func internalBind() {
        
        let member = self.memberUsecase.fetchCurrentMember()
        self.subjects.currentMember.accept(member)
        
        // TODO: 정책 정해야함
        let defaultKeyword = "Hooray".localized
        self.subjects.selectedHoorayKeyword.accept(defaultKeyword)
        
        self.userLocationUsecase.fetchUserLocation()
            .subscribe(onSuccess: { [weak self] location in
                guard let self = self, let member = member else { return }
                let newForm = NewHoorayForm(publisherID: member.uid)
                newForm.location = .init(latt: location.lattitude, long: location.longitude)
                newForm.hoorayKeyword = defaultKeyword
                self.subjects.pendingForm.accept(newForm)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MakeHoorayViewModelImple Interactor

extension MakeHoorayViewModelImple {
    
    private enum EnteringFlow: Int, CaseIterable {
        case message
        case tag
        case place
        
        func next() -> EnteringFlow? {
            let nextRawValue = self.rawValue + 1
            return .init(rawValue: nextRawValue)
        }
    }
    
    public func showUp() {
        
        let startEnteringAfterFormIsReady: (NewHoorayForm) -> Void = { [weak self] defaultForm in
            self?.enterHoorayInfo(defaultForm, currentFlow: .message)
        }
        
        self.subjects.pendingForm
            .compactMap{ $0 }.take(1)
            .subscribe(onNext: startEnteringAfterFormIsReady)
            .disposed(by: self.disposeBag)
    }
    
    private func messageInputMode(_ previousMessage: String?) -> TextInputMode {
        return .init(isSingleLine: false,
                     placeHolder: "placeHolder".localized,
                     startWith: previousMessage,
                     maxCharCount: 150,
                     shouldEnterSomething: true,
                     defaultHeight: 200)
    }
    
    private func enterHoorayInfo(_ form: NewHoorayForm,
                                 currentFlow: EnteringFlow, shouldContinue: Bool = true) {
        
        let nextFlow = currentFlow.next()
        
        var goNextStepWithForm: Observable<NewHoorayForm>?
        
        switch currentFlow {
        
        case .message:
            let inputMode = self.messageInputMode(form.message)
            goNextStepWithForm = self.router.openEnterHoorayMessageScene(form, inputMode: inputMode)
            
        case .tag:
            goNextStepWithForm = self.router.openEnterHoorayTagScene(form)?.goNextStepWithForm
            
        case .place:
            goNextStepWithForm = self.router.presentPlaceSelectScene(form)?.goNextStepWithForm
        }
        
        let updateForm: (NewHoorayForm) -> Void = { [weak self] newForm in
            self?.subjects.pendingForm.accept(newForm)
        }
        let continueEnteringOrNot: (NewHoorayForm) -> Void = { [weak self] newForm in
            guard shouldContinue, let next = nextFlow else { return }
            self?.enterHoorayInfo(newForm, currentFlow: next)
        }
        
        goNextStepWithForm?
            .take(1)
            .do(onNext: updateForm)
            .subscribe(onNext: continueEnteringOrNot)
            .disposed(by: self.disposeBag)
    }
    
    public func requestEnterMessage() {
        guard let form = self.subjects.pendingForm.value else { return }
        self.enterHoorayInfo(form, currentFlow: .message, shouldContinue: false)
    }
    
    public func requestEnterTags() {
        guard let form = self.subjects.pendingForm.value else { return }
        self.enterHoorayInfo(form, currentFlow: .tag, shouldContinue: false)
    }
    
    public func requestSelectPlace() {
        guard let form = self.subjects.pendingForm.value else { return }
        self.enterHoorayInfo(form, currentFlow: .place, shouldContinue: false)
    }
    
    public func requestPublishNewHooray() {
        
        guard self.subjects.isPublishing.value == false,
              let form = self.subjects.pendingForm.value else { return }
        
        let checkIsAvailable = self.hoorayPublishUsecase.isAvailToPublish()
        
        let thenRequestPulish: () -> Maybe<Hooray> = { [weak self] in
            return self?.hoorayPublishUsecase.publish(newHooray: form, withNewPlace: nil) ?? .empty()
        }
        
        let handleRequestFail: (Error) -> Void = { [weak self] error in
            self?.subjects.isPublishing.accept(false)
            guard let applicationError = error as? ApplicationErrors,
                  case let .shouldWaitPublishHooray(until) = applicationError else {
                self?.router.alertError(error)
                return
            }
            self?.router.alertShouldWaitPublishNewHooray(until)
        }
        
        let newHoorayPublished: (Hooray) -> Void = { [weak self] hooray in
            self?.subjects.isPublishing.accept(false)
            self?.closeAndEmitNewHoorayEvent(hooray)
        }
        
        self.subjects.isPublishing.accept(true)
        
        checkIsAvailable
            .flatMap(thenRequestPulish)
            .subscribe(onSuccess: newHoorayPublished, onError: handleRequestFail)
            .disposed(by: self.disposeBag)
    }
    
    private func closeAndEmitNewHoorayEvent(_ hooray: Hooray) {
        self.router.closeScene(animated: true) { [weak self] in
            
            self?.subjects.newHooray.onNext(hooray)
        }
    }
    
    public func requestEnterImage() {
        let alertWhenHasNoPermission: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        let askSelectMethod: () -> Void = { [weak self] in
            self?.presentImageSelectMethod()
        }
        self.permissionService.preparePermission(for: .readWrite)
            .subscribe(onSuccess: askSelectMethod,
                       onError: alertWhenHasNoPermission)
            .disposed(by: self.disposeBag)
    }
    
    private func presentImageSelectMethod() {
        
        let cameraAction: ActionSheetForm.Action = .init(text: "Camera") { [weak self] in
            self?.selectImage(true)
        }
        
        let libraryAction: ActionSheetForm.Action = .init(text: "Gallery") { [weak self] in
            self?.selectImage(false)
        }
        let close: ActionSheetForm.Action = .init(text: "Cancel", isCancel: true)
        
        let form = ActionSheetForm(title: nil, message: "[TBD] message")
        form.actions = [cameraAction, libraryAction, close]
        self.router.alertActionSheet(form)
    }
    
    private func selectImage(_ isCamera: Bool) {
        guard let form = self.subjects.pendingForm.value,
              let result = self.router.openEnterHoorayImageScene(form) else { return }
        
        let updateForm: (NewHoorayForm) -> Void = { [weak self] newForm in
            self?.subjects.pendingForm.accept(newForm)
        }
        
        let alertError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        result.take(1)
            .subscribe(onNext: updateForm, onError: alertError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MakeHoorayViewModelImple Presenter

extension MakeHoorayViewModelImple {
    
    public var hoorayKeyword: Observable<String> {
        return self.subjects.selectedHoorayKeyword.compactMap{ $0 }
    }
    
    public var selectedImagePath: Observable<String?> {
        return self.subjects.pendingForm
            .map{ $0?.imagePath }
            .distinctUntilChanged()
    }
    
    public var enteredMessage: Observable<String?> {
        return self.subjects.pendingForm
            .map{ $0?.message }
            .distinctUntilChanged()
    }
    
    public var enteredTags: Observable<[String]> {
        return self.subjects.pendingForm
            .map{ $0?.tags ?? [] }
            .distinctUntilChanged()
    }
    
    public var selectedPlaceName: Observable<String?> {
        return self.subjects.pendingForm
            .map{ $0?.placeName }
            .distinctUntilChanged()
    }
    
    public var isPublishable: Observable<Bool> {
//        return self.subjects.pendingInputMessage
//            .map{ $0.isNotEmpty }
//            .distinctUntilChanged()
        return .empty()
    }
    
    public var isPublishing: Observable<Bool> {
        return self.subjects.isPublishing.distinctUntilChanged()
    }
    
    public var publishedNewHooray: Observable<Hooray> {
        return self.subjects.newHooray.asObservable()
    }
}
