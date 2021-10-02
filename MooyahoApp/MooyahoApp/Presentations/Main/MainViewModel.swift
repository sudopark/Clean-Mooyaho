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

public protocol MainViewModel: AnyObject {

    // interactor
    func setupSubScenes()
    func openSlideMenu()
    func requestAddNewItem()
    
    // presenter
    var currentMemberProfileImage: Observable<Thumbnail> { get }
}


// MARK: - MainViewModelImple

public final class MainViewModelImple: MainViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let memberUsecase: MemberUsecase
    private let hoorayUsecase: HoorayUsecase
    private let router: MainRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private weak var readCollectionMainSceneInput: ReadCollectionMainSceneInput?
    
    public init(memberUsecase: MemberUsecase,
                hoorayUsecase: HoorayUsecase,
                router: MainRouting) {
        
        self.memberUsecase = memberUsecase
        self.hoorayUsecase = hoorayUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
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
        
        self.readCollectionMainSceneInput?.showSelectAddItemTypeScene()
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
 
    public var currentMemberProfileImage: Observable<Thumbnail> {
        return self.memberUsecase.currentMember
            .compactMap{ $0?.icon }
            .startWith(Member.memberDefaultEmoji)
    }
}
