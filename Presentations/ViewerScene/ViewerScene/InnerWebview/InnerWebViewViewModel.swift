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
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - InnerWebViewViewModel

public protocol InnerWebViewViewModel: AnyObject {

    // interactor
    func prepareLinkData()
    func openPageInSafari()
    func editReadLink()
    
    // presenter
    var loadURL: String { get }
    var urlPageTitle: Observable<String> { get }
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
        
        self.bindLinkItem(startWith: link)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let item = BehaviorRelay<ReadLink?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindLinkItem(startWith: ReadLink?) {
        
        self.subjects.item.accept(startWith)
    }
}


// MARK: - InnerWebViewViewModelImple Interactor

extension InnerWebViewViewModelImple {
    
    public func prepareLinkData() {
        
    }
    
    public func openPageInSafari() {
        self.router.openSafariBrowser(self.link.link)
    }
    
    public func editReadLink() {
        self.router.editReadLink(self.link)
    }
}


// MARK: - InnerWebViewViewModelImple Presenter

extension InnerWebViewViewModelImple {
    
    public var loadURL: String {
        return self.link.link
    }
    
    public var urlPageTitle: Observable<String> {
        
        typealias AddressAndTitle = (address: String, title: String?)
        let customNameInLinkItem = self.subjects.item.compactMap { $0 }
        let orUsePreviewTitle: (ReadLink) -> Observable<AddressAndTitle> = { [weak self] item in
            guard let self = self else { return .empty() }
            return item.customName?.emptyAsNil() != nil
                ? .just((item.link, item.customName))
                : self.readItemUsecase.previewTitle(for: item.link).map { (item.link, $0) }
                
        }
        let elseUseAddress: (AddressAndTitle) -> String = { $0.title?.emptyAsNil() ?? $0.address }
        
        return customNameInLinkItem
            .flatMapLatest(orUsePreviewTitle)
            .map(elseUseAddress)
            .distinctUntilChanged()
    }
}


private extension ReadItemUsecase {
    
    func previewTitle(for address: String) -> Observable<String?> {
        return self.loadLinkPreview(address)
            .map { $0.title }
    }
}
