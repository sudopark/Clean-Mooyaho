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
    
    // presenter
}


// MARK: - EditProfileViewModelImple

public final class EditProfileViewModelImple: EditProfileViewModel {
    
    enum PendinImageSource {
        case memoji(_ data: Data)
        case emoji(_ text: String)
    }
    
    private let usecase: MemberUsecase
    private let router: EditProfileRouting
    
    public init(usecase: MemberUsecase, router: EditProfileRouting) {
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
}


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
