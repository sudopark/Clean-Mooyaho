//
//  EditCategoryAttrViewModel.swift
//  SettingScene
//
//  Created sudo.park on 2021/12/04.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EditCategoryAttrViewModel

public protocol EditCategoryAttrViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditCategoryAttrViewModelImple

public final class EditCategoryAttrViewModelImple: EditCategoryAttrViewModel {
    
    private let router: EditCategoryAttrRouting
    private weak var listener: EditCategoryAttrSceneListenable?
    
    public init(router: EditCategoryAttrRouting,
                listener: EditCategoryAttrSceneListenable?) {
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


// MARK: - EditCategoryAttrViewModelImple Interactor

extension EditCategoryAttrViewModelImple {
    
}


// MARK: - EditCategoryAttrViewModelImple Presenter

extension EditCategoryAttrViewModelImple {
    
}
