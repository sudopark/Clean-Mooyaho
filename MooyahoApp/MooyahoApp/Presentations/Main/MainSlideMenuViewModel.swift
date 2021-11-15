//
//  MainSlideMenuViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/21.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


public enum SuggestingAction: Equatable {
    case signIn
    case editProfile(userName: String?)
    
    init(_ member: Member?) {
        switch member {
        case .none:
            self = .signIn
        case let .some(value):
            self = .editProfile(userName: value.nickName)
        }
    }
}

// MARK: - MainSlideMenuViewModel

public protocol MainSlideMenuViewModel: AnyObject {

    // interactor
    func refresh()
    func closeMenu()
    func openSetting()
//    func openAlert()
    func suggestingActionRequested()
    
    // presenter
    var suggestingAction: Observable<SuggestingAction> { get }
    var isDiscovable: Observable<Bool> { get }
}


// MARK: - MainSlideMenuViewModelImple

public final class MainSlideMenuViewModelImple: MainSlideMenuViewModel {
    
    fileprivate final class Subjects {
        // define subjects
        let currentMember = BehaviorRelay<Member?>(value: nil)
    }
    
    private let memberUsecase: MemberUsecase
    private let router: MainSlideMenuRouting
    private weak var listener: MainSlideMenuSceneListenable?
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
  
    public init(memberUsecase: MemberUsecase,
                router: MainSlideMenuRouting,
                listener: MainSlideMenuSceneListenable?) {
        self.memberUsecase = memberUsecase
        self.router = router
        self.listener = listener
        
        self.bindCurrentMember()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private func bindCurrentMember() {
        
        let updateMember: (Member?) -> Void = { [weak self] member in
            self?.subjects.currentMember.accept(member)
        }
        self.memberUsecase.currentMember
            .subscribe(onNext: updateMember)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MainSlideMenuViewModelImple Interactor

extension MainSlideMenuViewModelImple {
    
    public func refresh() {
        self.router.setupDiscoveryScene()
    }
    
    public func closeMenu() {
        self.router.closeMenu()
    }
    
    public func openSetting() {
        self.router.openSetting()
    }
    
    public func suggestingActionRequested() {
        let currentMember = self.subjects.currentMember.value
        let action = SuggestingAction(currentMember)
        
        switch action {
        case .signIn:
            self.closeSceneAndRequestSignIn()
             
        case .editProfile:
            self.router.editProfile()
        }
    }
    
    private func closeSceneAndRequestSignIn() {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.mainSlideMenuDidRequestSignIn()
        }
    }
    
    public func switchCollectionRequested() {
        self.router.closeMenu()
    }
}


// MARK: - MainSlideMenuViewModelImple Presenter

extension MainSlideMenuViewModelImple {
    
    public var suggestingAction: Observable<SuggestingAction> {
        return self.subjects.currentMember
            .map { SuggestingAction($0) }
            .distinctUntilChanged()
    }
    
    public var isDiscovable: Observable<Bool> {
        return self.subjects.currentMember
            .map { $0 != nil }
            .distinctUntilChanged()
    }
}
