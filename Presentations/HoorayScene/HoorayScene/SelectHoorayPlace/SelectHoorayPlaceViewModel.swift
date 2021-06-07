//
//  SelectHoorayPlaceViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - SelectHoorayPlaceViewModel

public protocol SelectHoorayPlaceViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - SelectHoorayPlaceViewModelImple

public final class SelectHoorayPlaceViewModelImple: SelectHoorayPlaceViewModel {
    
    private let form: NewHoorayForm
    private let selectedImagePath: String?
    private let router: SelectHoorayPlaceRouting
    
    public init(form: NewHoorayForm,
                selectedImagePath: String?,
                router: SelectHoorayPlaceRouting) {
        
        self.form = form
        self.selectedImagePath = selectedImagePath
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectHoorayPlaceViewModelImple Interactor

extension SelectHoorayPlaceViewModelImple {
    
}


// MARK: - SelectHoorayPlaceViewModelImple Presenter

extension SelectHoorayPlaceViewModelImple {
    
}
