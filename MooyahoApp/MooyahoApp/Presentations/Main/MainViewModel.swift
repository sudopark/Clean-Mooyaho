//
//  MainViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import MemberScenes
import CommonPresenting

// MARK: - MainViewModel

public enum SuggestAdditem {
    case suggest(String)
    case hide
}

public protocol MainViewModel: AnyObject {

    // interactor
    func setupSubScenes()
    func openSlideMenu()
    func requestAddNewItem()
    func requestAddNewItemUsingURLInClipBoard()
    func cancelAddNewItemUsingURLInCliipboard()
    func toggleIsReadItemShrinkMode()
    
    // presenter
    var currentMemberProfileImage: Observable<Thumbnail> { get }
    var isReadItemShrinkModeOn: Observable<Bool> { get }
    var showAddItemInUsingURLInClipBoard: Observable<SuggestAdditem> { get }
}


// MARK: - MainViewModelImple

public final class MainViewModelImple: MainViewModel {
    
    private let memberUsecase: MemberUsecase
    private let readItemOptionUsecase: ReadItemOptionsUsecase
    private let router: MainRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private weak var readCollectionMainSceneInput: ReadCollectionMainSceneInput?
    
    public init(memberUsecase: MemberUsecase,
                readItemOptionUsecase: ReadItemOptionsUsecase,
                router: MainRouting) {
        
        self.memberUsecase = memberUsecase
        self.readItemOptionUsecase = readItemOptionUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    fileprivate final class Subjects {
        let isReadItemShrinkModeOn = BehaviorRelay<Bool?>(value: nil)
        let suggestAddItemURL = BehaviorRelay<String?>(value: nil)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private func internalBinding() {
        
        self.readItemOptionUsecase
            .isShrinkModeOn
            .subscribe(onNext: { [weak self] isOn in
                self?.subjects.isReadItemShrinkModeOn.accept(isOn)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MainViewModelImple Interactor

extension MainViewModelImple {
    
    public func setupSubScenes() {
        self.readCollectionMainSceneInput = self.router.addReadCollectionScene()
    }
    
    public func openSlideMenu() {
        self.router.openSlideMenu()
    }
    
    public func requestAddNewItem() {
        
        self.router.askAddNewitemType { [weak self] isCollectionSelected in
            guard let input = self?.readCollectionMainSceneInput else { return }
            return isCollectionSelected
                ? input.addNewCollectionItem()
                : input.addNewReadLinkItem()
        }
    }
    
    public func requestAddNewItemUsingURLInClipBoard() {
        
    }
    
    public func cancelAddNewItemUsingURLInCliipboard() {
        
    }
    
    public func toggleIsReadItemShrinkMode() {
        guard let newValue = self.subjects.isReadItemShrinkModeOn.value?.invert() else { return }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.readItemOptionUsecase
            .updateLatestIsShrinkModeIsOn(newValue)
            .subscribe(onError: handleError)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
 
    public var currentMemberProfileImage: Observable<Thumbnail> {
        return self.memberUsecase.currentMember
            .compactMap{ $0?.icon }
            .startWith(Member.memberDefaultEmoji)
    }
    
    public var isReadItemShrinkModeOn: Observable<Bool> {
        return self.subjects
            .isReadItemShrinkModeOn
            .compactMap { $0 }
            .distinctUntilChanged()
    }
    
    public var showAddItemInUsingURLInClipBoard: Observable<SuggestAdditem> {
        return .empty()
    }
}
