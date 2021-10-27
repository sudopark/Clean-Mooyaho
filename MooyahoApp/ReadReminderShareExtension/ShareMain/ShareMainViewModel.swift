//
//  ShareMainViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/10/28.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - ShareMainViewModel

public protocol ShareMainViewModel: AnyObject {

    // interactor
    func showEditScene(_ url: String)
    
    // presenter
    var finishSharing: Observable<Void> { get }
}


// MARK: - ShareMainViewModelImple

public final class ShareMainViewModelImple: ShareMainViewModel {
    
    private let router: ShareMainRouting
    private weak var listener: ShareMainSceneListenable?
    
    public init(router: ShareMainRouting,
                listener: ShareMainSceneListenable?) {
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let itemAdded = PublishSubject<Void>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - ShareMainViewModelImple Interactor

extension ShareMainViewModelImple {
    
    public func showEditScene(_ url: String) {
        self.router.showEditScene(url)
    }
}

extension ShareMainViewModelImple: EditLinkItemSceneListenable {
    
    public func editReadLink(didEdit item: ReadLink) {
        self.subjects.itemAdded.onNext()
    }
}


// MARK: - ShareMainViewModelImple Presenter

extension ShareMainViewModelImple {
    
    public var finishSharing: Observable<Void> {
        return self.subjects.itemAdded.asObservable()
    }
}
