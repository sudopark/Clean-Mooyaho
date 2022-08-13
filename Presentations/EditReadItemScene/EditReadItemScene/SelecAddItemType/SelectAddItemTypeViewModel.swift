//
//  SelectAddItemTypeViewModel.swift
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


// MARK: - SelectAddItemTypeViewModel

public protocol SelectAddItemTypeViewModel: AnyObject, Sendable {

    // interactor
    func requestAddNewCollection()
    func requestAddNewReadLink()
    func closeScene()
    
    // presenter
}


// MARK: - SelectAddItemTypeViewModelImple

public final class SelectAddItemTypeViewModelImple: SelectAddItemTypeViewModel, @unchecked Sendable {
    
    private let router: SelectAddItemTypeRouting
    private var completed: ((Bool) -> Void)?
    
    public init(router: SelectAddItemTypeRouting,
                completed: @escaping (Bool) -> Void) {
        self.router = router
        self.completed = completed
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectAddItemTypeViewModelImple Interactor

extension SelectAddItemTypeViewModelImple {
    
    public func requestAddNewCollection() {
        self.close { [weak self] in
            self?.completed?(true)
        }
    }
    
    public func requestAddNewReadLink() {
        self.close { [weak self] in
            self?.completed?(false)
        }
    }
    
    private func close(and routing: @escaping @Sendable () -> Void) {
        self.router.closeScene(animated: true, completed: routing)
    }
    
    public func closeScene() {
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - SelectAddItemTypeViewModelImple Presenter

extension SelectAddItemTypeViewModelImple {
    
}
