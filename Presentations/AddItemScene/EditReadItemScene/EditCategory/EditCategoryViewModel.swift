//
//  EditCategoryViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


protocol SuggestingCategoryCellViewModelType {
    
    var name: String { get }
    var colorCode: String { get }
}

struct SuggestingCategoryCellViewModel: SuggestingCategoryCellViewModelType {
    let uid: String
    let name: String
    let colorCode: String
}

struct SuggestMakeNewCategoryCellViewMdoel: SuggestingCategoryCellViewModelType {
    let name: String
    let colorCode: String
}

// MARK: - EditCategoryViewModel

public protocol EditCategoryViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditCategoryViewModelImple

public final class EditCategoryViewModelImple: EditCategoryViewModel {
    
    private let router: EditCategoryRouting
    private weak var listener: EditCategorySceneListenable?
    
    public init(router: EditCategoryRouting,
                listener: EditCategorySceneListenable?) {
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


// MARK: - EditCategoryViewModelImple Interactor

extension EditCategoryViewModelImple {
    
}


// MARK: - EditCategoryViewModelImple Presenter

extension EditCategoryViewModelImple {
    
}
