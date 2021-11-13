//
//  DiscoveryMainViewModel.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/14.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - DiscoveryMainViewModel

public protocol DiscoveryMainViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - DiscoveryMainViewModelImple

public final class DiscoveryMainViewModelImple: DiscoveryMainViewModel {
    
    private let router: DiscoveryMainRouting
    private weak var listener: DiscoveryMainSceneListenable?
    
    public init(router: DiscoveryMainRouting,
                listener: DiscoveryMainSceneListenable?) {
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


// MARK: - DiscoveryMainViewModelImple Interactor

extension DiscoveryMainViewModelImple {
    
}


// MARK: - DiscoveryMainViewModelImple Presenter

extension DiscoveryMainViewModelImple {
    
}
