//
//  ReadCollectionMainViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - ReadCollectionMainViewModel

public protocol ReadCollectionMainViewModel: AnyObject {

    // interactor
    func setupSubCollections()
    func addNewCollectionItem()
    func addNewReadLinkItem()
    
    // presenter
}


// MARK: - ReadCollectionMainViewModelImple

public final class ReadCollectionMainViewModelImple: ReadCollectionMainViewModel {
    
    private let router: ReadCollectionMainRouting
    
    public init(router: ReadCollectionMainRouting) {
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


// MARK: - ReadCollectionMainViewModelImple Interactor

extension ReadCollectionMainViewModelImple {
    
    public func setupSubCollections() {
        self.router.setupSubCollections()
    }
    
    public func addNewCollectionItem() {
        self.router.addNewColelctionAtCurrentCollection()
    }
    
    public func addNewReadLinkItem() {
        self.router.addNewReadLinkItemAtCurrentCollection()
    }
}


// MARK: - ReadCollectionMainViewModelImple Presenter

extension ReadCollectionMainViewModelImple {
    
}
