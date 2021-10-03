//
//  AddItemNavigationViewModel.swift
//  AddItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - AddItemNavigationViewModel

public protocol AddItemNavigationViewModel: AnyObject {

    // interactor
    func prepareNavigation()
    func requestpopToEnrerURLScene()
    
    // presenter
}


// MARK: - AddItemNavigationViewModelImple

public final class AddItemNavigationViewModelImple: AddItemNavigationViewModel {
    
    private let targetCollectionID: String?
    private var newLinkItemAddedCallback: (ReadLink) -> Void
    private let router: AddItemNavigationRouting
    
    public init(targetCollectionID: String?,
                router: AddItemNavigationRouting,
                _ completed: @escaping (ReadLink) -> Void) {
        self.targetCollectionID = targetCollectionID
        self.newLinkItemAddedCallback = completed
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


// MARK: - AddItemNavigationViewModelImple Interactor

extension AddItemNavigationViewModelImple {
    
    public func prepareNavigation() {
        self.router.prepareNavigation()
        self.moveToEnterLinkURL()
    }
    
    private func moveToEnterLinkURL() {
        
        let handleEnteredURL: (String) -> Void = { [weak self] url in
            guard let self = self else { return }
            self.moveToConfirmAddItemScene(with: url)
        }
        self.router.pushToEnterURLScene(handleEnteredURL)
    }
    
    private func moveToConfirmAddItemScene(with url: String) {
        
        let handleItemAdded: (ReadLink) -> Void = { [weak self] newLink in
            self?.closeAfterItemAdded(newLink)
        }
        
        self.router.pushConfirmAddLinkItemScene(at: self.targetCollectionID,
                                                url: url,
                                                handleItemAdded)
    }
    
    private func closeAfterItemAdded(_ newLink: ReadLink) {
        
        self.router.closeScene(animated: true) { [weak self] in
            self?.newLinkItemAddedCallback(newLink)
        }
    }
    
    public func requestpopToEnrerURLScene() {
        self.router.popToEnrerURLScene()
    }
}


// MARK: - AddItemNavigationViewModelImple Presenter

extension AddItemNavigationViewModelImple {
    
}
