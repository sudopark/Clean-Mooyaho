//
//  MemberProfileViewModel.swift
//  MemberScenes
//
//  Created sudo.park on 2021/12/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - MemberProfileViewModel

public protocol MemberProfileViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - MemberProfileViewModelImple

public final class MemberProfileViewModelImple: MemberProfileViewModel {
    
    private let router: MemberProfileRouting
    private weak var listener: MemberProfileSceneListenable?
    
    public init(router: MemberProfileRouting,
                listener: MemberProfileSceneListenable?) {
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


// MARK: - MemberProfileViewModelImple Interactor

extension MemberProfileViewModelImple {
    
}


// MARK: - MemberProfileViewModelImple Presenter

extension MemberProfileViewModelImple {
    
}
