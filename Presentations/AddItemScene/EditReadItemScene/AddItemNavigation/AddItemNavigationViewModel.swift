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
    
    private let startWithURL: String?
    private let targetCollectionID: String?
    private let router: AddItemNavigationRouting
    private weak var listener: AddItemNavigationSceneListenable?
    
    public init(startWith url: String?,
                targetCollectionID: String?,
                router: AddItemNavigationRouting,
                listener: AddItemNavigationSceneListenable?) {
        self.startWithURL = url
        self.targetCollectionID = targetCollectionID
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


// MARK: - AddItemNavigationViewModelImple Interactor

extension AddItemNavigationViewModelImple {
    
    public func prepareNavigation() {
        self.router.prepareNavigation()
        self.moveToEnterLinkURL(startWith: self.startWithURL)
    }
    
    private func moveToEnterLinkURL(startWith url: String? = nil) {
        
        let handleEnteredURL: (String) -> Void = { [weak self] url in
            guard let self = self else { return }
            self.moveToConfirmAddItemScene(with: url)
        }
        self.router.pushToEnterURLScene(startWith: url, handleEnteredURL)
    }
    
    private func moveToConfirmAddItemScene(with url: String) {
        
        self.router.pushConfirmAddLinkItemScene(at: self.targetCollectionID, url: url)
    }
    
    public func requestpopToEnrerURLScene() {
        self.router.popToEnrerURLScene()
    }
    
    public func editReadLink(didEdit item: ReadLink) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.addReadLink(didAdded: item)
        }
    }
}


// MARK: - AddItemNavigationViewModelImple Presenter

extension AddItemNavigationViewModelImple {
    
}
