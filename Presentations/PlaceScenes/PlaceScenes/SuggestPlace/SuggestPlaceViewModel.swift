//
//  SuggestPlaceViewModel.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/05/28.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import CommonPresenting

// MARK: - SuggestPlaceViewModel

public protocol SuggestPlaceViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - SuggestPlaceViewModelImple

public final class SuggestPlaceViewModelImple: SuggestPlaceViewModel {
    
    private let router: SuggestPlaceRouting
    private let listener: Listener<SuggestSceneEvents>
    
    public init(router: SuggestPlaceRouting,
                listener: @escaping Listener<SuggestSceneEvents>) {
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        // define subjects
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SuggestPlaceViewModelImple Interactor

extension SuggestPlaceViewModelImple {
    
}


// MARK: - SuggestPlaceViewModelImple Presenter

extension SuggestPlaceViewModelImple {
    
}
