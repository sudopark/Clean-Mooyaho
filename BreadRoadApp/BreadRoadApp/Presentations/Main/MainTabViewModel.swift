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

public protocol MainTabViewModel: class {

    // interactor
    
    // presenter
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel

public final class MainTabViewModelImple: MainTabViewModel {
    
    public let router: MainTabRouting
    
    public init(router: MainTabRouting) {
        self.router = router
    }
    
    
    private let disposeBag = DisposeBag()
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Interactor

extension MainTabViewModelImple {
    
}


// MARK: - ___VARIABLE_sceneModuleName___ViewModel Presenter

extension MainTabViewModelImple {
    
}
