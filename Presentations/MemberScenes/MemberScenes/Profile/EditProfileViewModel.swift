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

import Domain
import CommonPresenting

// MARK: - EditProfileViewModel

public enum EditProfileCellType: String {
    case nickName
    case introduction
}

public protocol EditProfileViewModel: AnyObject {

    // interactor
    func selectMemoji(_ data: Data)
    func selectEmoji(_ emoji: String)
    func inputTextChanges(type: EditProfileCellType, to newValue: String?)
    func saveChanges()
    func requestCloseScene()
    
    // presenter
    var profileImageSource: Observable<ImageSource?> { get }
    var cellTypes: Observable<[EditProfileCellType]> { get }
    func previousInputValue(for cellType: EditProfileCellType) -> String?
    var isSavable: Observable<Bool> { get }
    var isSaveChanges: Observable<Bool> { get }
    var editCompleted: Observable<Void> { get }
}


// MARK: - EditProfileViewModelImple

public final class EditProfileViewModelImple: EditProfileViewModel {
    
    enum PendinImageSource {
        case memoji(_ data: Data)
        case emoji(_ text: String)
    }
    
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
        let pendingImageSource = BehaviorRelay<PendinImageSource?>(value: nil)
        let pendingInputs = BehaviorRelay<[EditProfileCellType: String]>(value: [:])
        let cellViewModels = BehaviorRelay<[EditProfileCellType]>(value: [])
        let isSaveChanges = BehaviorRelay<Bool>(value: false)
        let isSaveCompleted = PublishSubject<Void>()
    }
    private let disposeBag = DisposeBag()
    private let subjects = Subjects()
}


// MARK: - EditProfileViewModelImple Interactor

extension EditProfileViewModelImple {
    
    public func selectMemoji(_ data: Data) {
        self.subjects.pendingImageSource.accept(.memoji(data))
    }
    
    public func selectEmoji(_ emoji: String) {
        self.subjects.pendingImageSource.accept(.emoji(emoji))
    }
    
    public func inputTextChanges(type: EditProfileCellType, to newValue: String?) {
        
        var pendinMap = self.subjects.pendingInputs.value
        pendinMap[type] = newValue
        self.subjects.pendingInputs.accept(pendinMap)
    }
    
    public func saveChanges() {
        
        guard self.subjects.isSaveChanges.value == false,
              let memberID = self.subjects.currentMember.value?.uid else { return }
        
        let pendingInputs = self.subjects.pendingInputs.value
        let fields: [MemberUpdateField] = pendingInputs.compactMap{ .init(type: $0.key, value: $0.value) }
        
        let handleStatus: (UpdateMemberProfileStatus) -> Void = { [weak self] status in
            switch status {
            case .finished:
                self?.subjects.isSaveChanges.accept(false)
                self?.router.closeScene(animated: true) { [weak self] in
                    self?.subjects.isSaveCompleted.onNext()
                }
                
            case let .finishedWithImageUploadFail(error):
                self?.subjects.isSaveChanges.accept(false)
                self?.router.showToast("프로필 사진 업로드에 실패했습니다. 다시 시도해보세요.".localized)
                // TODO: record error
                
            default: break
            }
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isSaveChanges.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isSaveChanges.accept(true)
        self.usecase.updateCurrent(memberID: memberID, updateFields: fields, with: nil)
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
    
    public var profileImageSource: Observable<ImageSource?> {
        return self.subjects.currentMember
            .compactMap{ $0 }
            .map{ $0?.icon }
            .distinctUntilChanged()
    }
    
    public var cellTypes: Observable<[EditProfileCellType]> {
        return self.subjects.currentMember
            .compactMap{ $0 }
            .map { _ in
                return [.nickName, .introduction]
            }
    }
    
    public func previousInputValue(for cellType: EditProfileCellType) -> String? {
        let pendings = self.subjects.pendingInputs.value
        return pendings[cellType]
    }
    
    public var isSavable: Observable<Bool> {
        
        let checkHasChanged: (Member, PendinImageSource?, [EditProfileCellType: String]) -> Bool
        checkHasChanged = { member, source, dict in
            guard dict.isNickNameEntered else { return false }
            let hasNewImageSource = source != nil
            return hasNewImageSource || member.isChangeOccurs(dict)
        }
        
        return Observable
            .combineLatest(self.subjects.currentMember.compactMap{ $0 },
                           self.subjects.pendingImageSource,
                           self.subjects.pendingInputs)
            .map(checkHasChanged)
            .distinctUntilChanged()
    }
    
    public var isSaveChanges: Observable<Bool> {
        return self.subjects.isSaveChanges
            .distinctUntilChanged()
    }
    
    public var editCompleted: Observable<Void> {
        return self.subjects.isSaveCompleted
    }
}


// MARK: - private extensiosns

private extension EditProfileViewModelImple {
    
    func internalBind() {
        
        let member = self.usecase.fetchCurrentMember()
        var previousValueMap: [EditProfileCellType: String] = [:]
        previousValueMap[.nickName] = member?.nickName
        previousValueMap[.introduction] = member?.introduction
            
        self.subjects.pendingInputs.accept(previousValueMap)
        self.subjects.currentMember.accept(member)
    }
}

private extension Dictionary where Key == EditProfileCellType, Value == String {
    
    var isNickNameEntered: Bool {
        return self[.nickName]?.isNotEmpty == true
    }
}

private extension Member {
    
    func isChangeOccurs(_ dict: [EditProfileCellType: String]) -> Bool {
        return self.nickName != dict[.nickName] || self.introduction != dict[.introduction]
    }
}


extension MemberUpdateField {
        
    init?(type: EditProfileCellType, value: String) {
        switch type {
        case .nickName where value.isNotEmpty:
            self = .nickName(value)
            
        case .introduction:
            self = .introduction(value.isEmpty ? nil : value)
        default: return nil
        }
    }
}
