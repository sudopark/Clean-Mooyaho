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

public struct HoorayTag {
    let identifier: String
    let text: String
}

public protocol MakeHoorayViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - MakeHoorayViewModelImple

public final class MakeHoorayViewModelImple: MakeHoorayViewModel {
    
    private let memberUsecase: MemberUsecase
    private let hoorayPublishUsecase: HoorayPublisherUsecase
    private let router: MakeHoorayRouting
    
    public init(memberUsecase: MemberUsecase,
                hoorayPublishUsecase: HoorayPublisherUsecase,
                router: MakeHoorayRouting) {
        self.memberUsecase = memberUsecase
        self.hoorayPublishUsecase = hoorayPublishUsecase
        self.router = router
    
        self.internalBind()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let currentMember = BehaviorRelay<Member?>(value: nil)
        let pendingInputMessage = BehaviorRelay<String>(value: "")
        let pendingInputTags = BehaviorRelay<[String]>(value: [])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - MakeHoorayViewModelImple Interactor

extension MakeHoorayViewModelImple {
 
    public func requestChangeMemnerProfileImage() {
        _ = self.router.openEditProfileScene()
    }
    
    public func enterHooray(message: String) {
        self.subjects.pendingInputMessage.accept(message)
    }
    
    public func enterHooray(tags: [HoorayTag]) {
        // TODO: store tag
    }
    
    public func requestSelectPlace() {
        self.router.presentPlaceSelectScene()
    }
}


// MARK: - MakeHoorayViewModelImple Presenter

extension MakeHoorayViewModelImple {
    
    public var memberProfileImage: Observable<ImageSource> {
        return self.subjects.currentMember.compactMap{ $0 }
            .map{ $0.icon ?? Member.memberDefaultEmoji }
    }
    
    public var hoorayKeyword: Observable<String> {
        // TODO: 정책 정해야함
        let defaultKeyword = "Hooray".localized
        return .just(defaultKeyword)
    }
    
    public var isPublishable: Observable<Bool> {
        return self.subjects.pendingInputMessage
            .map{ $0.isNotEmpty }
            .distinctUntilChanged()
    }
}


// internal bindinds

private extension MakeHoorayViewModelImple {
    
    func internalBind() {
        
        let member = self.memberUsecase.fetchCurrentMember()
        self.subjects.currentMember.accept(member)
    }
}
