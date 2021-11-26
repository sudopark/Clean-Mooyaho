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
    private weak var navigationListener: ReadCollectionNavigateListenable?
    
    public init(router: ReadCollectionMainRouting,
                navigationListener: ReadCollectionNavigateListenable?) {
        self.router = router
        self.navigationListener = navigationListener
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
        self.notifyRootCollectionDidChanged(.myCollections)
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
        self.notifyRootCollectionDidChanged(.sharedCollection(collection))
        self.router.switchToSharedCollection(root: collection)
    }
    
    public func switchToMyReadCollections() {
        self.notifyRootCollectionDidChanged(.myCollections)
        self.router.switchToMyReadCollection()
    }
    
    public var rootType: CollectionRoot {
        return self.subjects.currentCollectionRoot.value
    }
    
    private func notifyRootCollectionDidChanged(_ root: CollectionRoot) {
        self.subjects.currentCollectionRoot.accept(root)
        self.navigationListener?.readCollection(didChange: root)
    }
    
    public func jumpToCollection(_ collectionID: String?) {
        if let subCollectionID = collectionID {
            self.router.jumpToCollection(subCollectionID)
        } else {
            self.router.moveToRootCollection()
        }
    }
}
