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
        let currentCollectionRoot = BehaviorRelay<CollectionRoot>(value: .myCollections)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - ReadCollectionMainViewModelImple Interactor

extension ReadCollectionMainViewModelImple {
    
    public func setupSubCollections() {
        self.subjects.currentCollectionRoot.accept(.myCollections)
        self.router.setupSubCollections()
    }
    
    public func addNewCollectionItem() {
        self.router.addNewColelctionAtCurrentCollection()
    }
    
    public func addNewReadLinkItem() {
        self.router.addNewReadLinkItemAtCurrentCollection()
    }
    
    public func addNewReaedLinkItem(with url: String) {
        self.router.addNewReadLinkItem(using: url)
    }
    
    public func switchToSharedCollection(_ collection: SharedReadCollection) {
        self.subjects.currentCollectionRoot.accept(.sharedCollection(collection))
        logger.todoImplement()
    }
    
    public func switchToMyReadCollections() {
        self.subjects.currentCollectionRoot.accept(.myCollections)
        logger.todoImplement()
    }
    
    public var rootType: CollectionRoot {
        return self.subjects.currentCollectionRoot.value
    }
}
