//
//  InnerWebViewViewModel.swift
//  ViewerScene
//
//  Created sudo.park on 2021/10/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - InnerWebViewViewModel

public protocol InnerWebViewViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - InnerWebViewViewModelImple

public final class InnerWebViewViewModelImple: InnerWebViewViewModel {
    
    private let link: ReadLink
    private let readItemUsecase: ReadItemUsecase
    private let router: InnerWebViewRouting
    
    public init(link: ReadLink,
                readItemUsecase: ReadItemUsecase,
                router: InnerWebViewRouting) {
        
        self.link = link
        self.readItemUsecase = readItemUsecase
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


// MARK: - InnerWebViewViewModelImple Interactor

extension InnerWebViewViewModelImple {
    
}


// MARK: - InnerWebViewViewModelImple Presenter

extension InnerWebViewViewModelImple {
    
}
