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

public protocol EnterLinkURLViewModel: AnyObject, Sendable {

    // interactor
    func enterURL(_ address: String)
    func confirmEnter()
    
    // presenter
    var startWithURL: String? { get }
    var isConfirmable: Observable<Bool> { get }
    func startAutoEnterURLIfNeed()
}


// MARK: - EnterLinkURLViewModelImple

public final class EnterLinkURLViewModelImple: EnterLinkURLViewModel, @unchecked Sendable {
    
    public let startWithURL: String?
    private let callback: @Sendable (String) -> Void
    private let router: EnterLinkURLRouting
    
    public init(startWith url: String?,
                router: EnterLinkURLRouting,
                callback: @escaping @Sendable (String) -> Void) {
        
        self.startWithURL = url
        self.router = router
        self.callback = callback
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let inputURLAddress = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - EnterLinkURLViewModelImple Interactor

extension EnterLinkURLViewModelImple {
    
    public func startAutoEnterURLIfNeed() {
        guard let startURL = self.startWithURL else { return }
        self.subjects.inputURLAddress.accept(startURL)
        
        self.callback(startURL)
    }
    
    public func enterURL(_ address: String) {
        self.subjects.inputURLAddress.accept(address)
    }
    
    public func confirmEnter() {
        
        guard let url = self.subjects.inputURLAddress
            .value?.trimmingCharacters(in: .whitespacesAndNewlines)
        else { return }
        
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
