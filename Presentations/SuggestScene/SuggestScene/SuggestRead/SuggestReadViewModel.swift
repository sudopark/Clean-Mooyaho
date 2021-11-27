//
//  SuggestReadViewModel.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/27.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - SuggestReadViewModel

public protocol SuggestReadViewModel: AnyObject {

    // interactor
    
    
    // presenter
}


// MARK: - SuggestReadViewModelImple

public final class SuggestReadViewModelImple: SuggestReadViewModel {
    
    private let router: SuggestReadRouting
    private weak var listener: SuggestReadSceneListenable?
    
    public init(router: SuggestReadRouting,
                listener: SuggestReadSceneListenable?) {
        self.router = router
        self.listener = listener
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


// MARK: - SuggestReadViewModelImple Interactor

extension SuggestReadViewModelImple {
    
}


// MARK: - SuggestReadViewModelImple Presenter

extension SuggestReadViewModelImple {
    
}
