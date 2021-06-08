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
    var goNextStepWithForm: Observable<NewHoorayForm> { get }
}


// MARK: - SelectHoorayPlaceViewModelImple

public final class SelectHoorayPlaceViewModelImple: SelectHoorayPlaceViewModel {
    
    private let form: NewHoorayForm
    private let router: SelectHoorayPlaceRouting
    
    public init(form: NewHoorayForm,
                router: SelectHoorayPlaceRouting) {
        
        self.form = form
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let continueNext = PublishSubject<NewHoorayForm>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectHoorayPlaceViewModelImple Interactor

extension SelectHoorayPlaceViewModelImple {
    
}


// MARK: - SelectHoorayPlaceViewModelImple Presenter

extension SelectHoorayPlaceViewModelImple {
    
    public var goNextStepWithForm: Observable<NewHoorayForm> {
        return self.subjects.continueNext.asObservable()
    }
}
