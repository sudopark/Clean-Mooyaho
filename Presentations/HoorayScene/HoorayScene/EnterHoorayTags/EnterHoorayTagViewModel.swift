//
//  EnterHoorayTagViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/07.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - EnterHoorayTagViewModel

public protocol EnterHoorayTagViewModel: AnyObject {

    // interactor
    func skipInput()
    func goNextInputStage(with tags: [String])
    
    // presenter
}


// MARK: - EnterHoorayTagViewModelImple

public final class EnterHoorayTagViewModelImple: EnterHoorayTagViewModel {
    
    private let form: NewHoorayForm
    private let selectedImagePath: String?
    private let router: EnterHoorayTagRouting
    
    public init(form: NewHoorayForm,
                selectedImagePath: String?,
                router: EnterHoorayTagRouting) {
        
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


// MARK: - EnterHoorayTagViewModelImple Interactor

extension EnterHoorayTagViewModelImple {
    
    public func skipInput() {
        self.router.presentNextInputStage(form, selectedImage: selectedImagePath)
    }
    
    public func goNextInputStage(with tags: [String]) {
        self.form.tags = tags
        self.router.presentNextInputStage(form, selectedImage: selectedImagePath)
    }
}


// MARK: - EnterHoorayTagViewModelImple Presenter

extension EnterHoorayTagViewModelImple {
    
}
