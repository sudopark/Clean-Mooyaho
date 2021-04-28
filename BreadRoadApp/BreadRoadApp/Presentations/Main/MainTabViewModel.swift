//
//  MainTabViewModel.swift
//  BreadRoadApp
//
//  Created ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay


// MARK: - MainTabViewModel

public protocol MainTabViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel

public final class MainTabViewModelImple: MainTabViewModel {
    
    fileprivate final class Subjects {
        // TODO: define subjects
    }
    
    private let router: MainTabRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    
    public init(router: MainTabRouting) {
        self.router = router
    }
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Interactor

extension MainTabViewModelImple {
    
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Presenter

extension MainTabViewModelImple {
    
}
