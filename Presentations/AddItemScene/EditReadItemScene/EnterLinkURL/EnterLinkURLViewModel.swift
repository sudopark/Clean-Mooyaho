//
//  EnterLinkURLViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EnterLinkURLViewModel

public protocol EnterLinkURLViewModel: AnyObject {

    // interactor
    func enterURL(_ address: String)
    func confirmEnter()
    
    // presenter
    var isConfirmable: Observable<Bool> { get }
}


// MARK: - EnterLinkURLViewModelImple

public final class EnterLinkURLViewModelImple: EnterLinkURLViewModel {
    
    private let callback: (String) -> Void
    private let router: EnterLinkURLRouting
    
    public init(router: EnterLinkURLRouting, callback: @escaping (String) -> Void) {
        self.router = router
        self.callback = callback
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let inputURLAddress = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterLinkURLViewModelImple Interactor

extension EnterLinkURLViewModelImple {
    
    public func enterURL(_ address: String) {
        self.subjects.inputURLAddress.accept(address)
    }
    
    public func confirmEnter() {
        
        guard let url = self.subjects.inputURLAddress.value else { return }
        self.callback(url)
    }
}


// MARK: - EnterLinkURLViewModelImple Presenter

extension EnterLinkURLViewModelImple {
    
    public var isConfirmable: Observable<Bool> {
        return self.subjects.inputURLAddress
            .map { $0?.isURLAddress ?? false }
            .distinctUntilChanged()
    }
}
