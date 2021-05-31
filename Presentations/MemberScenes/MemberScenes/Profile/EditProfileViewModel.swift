//
//  EditProfileViewModel.swift
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import CommonPresenting

// MARK: - EditProfileViewModel

public protocol EditProfileViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - EditProfileViewModelImple

public final class EditProfileViewModelImple: EditProfileViewModel {
    
    fileprivate final class Subjects {
        // define subjects
    }
    
    private let router: EditProfileRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    public init(router: EditProfileRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
}


// MARK: - EditProfileViewModelImple Interactor

extension EditProfileViewModelImple {
    
}


// MARK: - EditProfileViewModelImple Presenter

extension EditProfileViewModelImple {
    
}
