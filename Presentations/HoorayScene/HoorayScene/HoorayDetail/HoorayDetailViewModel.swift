//
//  HoorayDetailViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/08/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - HoorayDetailViewModel

public protocol HoorayDetailViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - HoorayDetailViewModelImple

public final class HoorayDetailViewModelImple: HoorayDetailViewModel {
    
    private let hoorayUsecase: HoorayUsecase
    private let memberUsecase: MemberUsecase
    private let router: HoorayDetailRouting
    
    public init(hoorayUsecase: HoorayUsecase,
                memberUsecase: MemberUsecase,
                router: HoorayDetailRouting) {
        self.hoorayUsecase = hoorayUsecase
        self.memberUsecase = memberUsecase
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - HoorayDetailViewModelImple Interactor

extension HoorayDetailViewModelImple {
    
}


// MARK: - HoorayDetailViewModelImple Presenter

extension HoorayDetailViewModelImple {
    
}
