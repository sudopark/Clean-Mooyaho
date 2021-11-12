//
//  EditProfileViewModel.swift
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting

// MARK: - EditProfileViewModel

public struct EditProfileCellViewModel: Equatable {
    
    public enum InputType {
        case nickname
        case intro
    }
    
    let inputType: InputType
    let value: String?
    var isRequire = false
}

public protocol EditProfileViewModel: AnyObject {

    // interactor
    func requestChangeThumbnail()
    func requestChangeProperty(_ inputType: EditProfileCellViewModel.InputType)
    func saveChanges()
    func requestCloseScene()
    
    // presenter
    var profileImageSource: Observable<Thumbnail?> { get }
    var cellViewModels: Observable<[EditProfileCellViewModel]> { get }
    var isSavable: Observable<Bool> { get }
    var isSaveChanges: Observable<Bool> { get }
    var editCompleted: Observable<Void> { get }
}


// MARK: - EditProfileViewModelImple

public final class EditProfileViewModelImple: EditProfileViewModel {
    
    private let usecase: MemberUsecase
    private let router: EditProfileRouting
    
    public init(usecase: MemberUsecase,
                router: EditProfileRouting) {
        self.usecase = usecase
        self.router = router
        self.internalBind()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        // define subjects
        let currentMember = BehaviorRelay<Member?>(value: nil)
        let pendingImageInfo = BehaviorRelay<(String, ImageSize)?>(value: nil)
        let pendingNickName = BehaviorRelay<String?>(value: nil)
        let pendingIntroduction = BehaviorRelay<String?>(value: nil)
        let isSaveChanges = BehaviorRelay<Bool>(value: false)
        @AutoCompletable var isSaveCompleted = PublishSubject<Void>()
    }
    private let disposeBag = DisposeBag()
    private let subjects = Subjects()
    
    private func internalBind() {
        
        let member = self.usecase.fetchCurrentMember()
        self.subjects.currentMember.accept(member)
    }
}


// MARK: - EditProfileViewModelImple Interactor

extension EditProfileViewModelImple {
    
    public func requestChangeThumbnail() {
        // TODO: ask image source(image or emoji)
    }
    
    public func requestChangeProperty(_ inputType: EditProfileCellViewModel.InputType) {
        // TODO: open text edit
    }
    
    public func saveChanges() {
        
        guard self.subjects.isSaveChanges.value == false,
              let memberID = self.subjects.currentMember.value?.uid else { return }
        
        let pendingNickname = self.subjects.pendingNickName.value?.emptyAsNil()
            .map { MemberUpdateField.nickName($0) }
        let pendingIntro = self.subjects.pendingIntroduction.value
            .map { MemberUpdateField.introduction($0.emptyAsNil()) }
        
        let fields = [pendingNickname, pendingIntro].compactMap { $0 }
        let imageInput = self.subjects.pendingImageInfo.value
            .map { ImageUploadReqParams.file($0.0, needCopyTemp: true, size: $0.1) }
        
        let handleStatus: (UpdateMemberProfileStatus) -> Void = { [weak self] status in
            switch status {
            case .finished:
                self?.subjects.isSaveChanges.accept(false)
                self?.router.closeScene(animated: true, completed: nil)
                
            case let .finishedWithImageUploadFail(error):
                logger.print(level: .error, error.localizedDescription)
                self?.subjects.isSaveChanges.accept(false)
                self?.router.showToast("프로필 사진 업로드에 실패했습니다. 다시 시도해보세요.".localized)
                
            default: break
            }
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isSaveChanges.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isSaveChanges.accept(true)
        self.usecase.updateCurrent(memberID: memberID, updateFields: fields, with: imageInput)
            .subscribe(onNext: handleStatus, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func requestCloseScene() {
        let isSaving = self.subjects.isSaveChanges.value
        guard isSaving == true else {
            self.router.closeScene(animated: true, completed: nil)
            return
        }
        
        let confirmClose: () -> Void = { [weak self] in
            self?.router.closeScene(animated: true, completed: nil)
        }
        
        guard let form = AlertBuilder(base: .init())
                .title("Warning".localized)
                .message("[TBD] saving description".localized)
                .confirmed(confirmClose)
                .build() else { return }
        self.router.alertForConfirm(form)
    }
}


// MARK: - EditProfileViewModelImple Presenter

extension EditProfileViewModelImple {
    
    public var profileImageSource: Observable<MemberThumbnail?> {
        let selectThumbnail: (Member?, (String, ImageSize)?) -> MemberThumbnail?
        selectThumbnail = { member, selectedInfo in
            return selectedInfo.map { ImageSource(path: $0.0, size: $0.1) }.map { .imageSource($0) }
                ?? member?.icon
                
        }
        let bothNilThenDefaultImage: (MemberThumbnail?) -> MemberThumbnail
        bothNilThenDefaultImage = {
            return $0 ?? Member.memberDefaultEmoji
        }
        return Observable
            .combineLatest(self.subjects.currentMember, self.subjects.pendingImageInfo,
                           resultSelector: selectThumbnail)
            .map(bothNilThenDefaultImage)
            .distinctUntilChanged()
    }
    
    private var nicknamecell: Observable<EditProfileCellViewModel> {
        
        let selectValue: (Member, String?) -> String? = { member, editedValue in
            return editedValue?.emptyAsNil() ?? member.nickName
        }
        return Observable
            .combineLatest(self.subjects.currentMember.compactMap { $0 },
                           self.subjects.pendingNickName,
                           resultSelector: selectValue)
            .map {
                return EditProfileCellViewModel(inputType: .nickname, value: $0)
                    |> \.isRequire .~ true
            }
    }
    
    private var introCell: Observable<EditProfileCellViewModel> {
        
        let selectValue: (Member, String?) -> String? = { member, editedValue in
            return editedValue?.emptyAsNil() ?? member.introduction
        }
        return Observable
            .combineLatest(self.subjects.currentMember.compactMap { $0 },
                           self.subjects.pendingIntroduction,
                           resultSelector: selectValue)
            .map {
                return EditProfileCellViewModel(inputType: .intro, value: $0)
            }
    }
    
    public var cellViewModels: Observable<[EditProfileCellViewModel]> {
        return Observable
            .combineLatest(self.nicknamecell, self.introCell,
                           resultSelector: { [$0, $1] })
    }
    
    public var isSavable: Observable<Bool> {
        
        let checkHasNickname: (Member, String?) -> Bool = { member, editedNickname in
            let hasNickname = (editedNickname?.emptyAsNil() ?? member.nickName?.emptyAsNil()) != nil
            return hasNickname
        }
        
        return Observable
            .combineLatest(self.subjects.currentMember.compactMap{ $0 },
                           self.subjects.pendingNickName)
            .map(checkHasNickname)
            .distinctUntilChanged()
    }
    
    public var isSaveChanges: Observable<Bool> {
        return self.subjects.isSaveChanges
            .distinctUntilChanged()
    }
    
    public var editCompleted: Observable<Void> {
        return self.subjects.isSaveCompleted.asObservable()
    }
}
