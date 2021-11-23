//
//  IntegratedSearchViewModel.swift
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - IntegratedSearchViewModel

public protocol IntegratedSearchViewModel: AnyObject {

    // interactor
    func setupSubScene()
    func requestSuggest(with text: String)
    func requestSearchItems(with text: String)
    
    // presenter
}


// MARK: - IntegratedSearchViewModelImple

public final class IntegratedSearchViewModelImple: IntegratedSearchViewModel {
    
    private let router: IntegratedSearchRouting
    private weak var listener: IntegratedSearchSceneListenable?
    
    public init(router: IntegratedSearchRouting,
                listener: IntegratedSearchSceneListenable?) {
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
    
    private weak var suggestInteractor: SuggestQuerySceneInteractable?
}


// MARK: - IntegratedSearchViewModelImple Interactor

extension IntegratedSearchViewModelImple {
    
    public func setupSubScene() {
        self.suggestInteractor = self.router.setupSuggestScene()
        // TOOD: 셋업하고 이전 검색어 있으면 바로 연결
    }
    
    public func requestSuggest(with text: String) {
        // TODO: 서제스트 화면 숨겨져 있으면 보이기
        self.suggestInteractor?.suggest(with: text)
    }
    
    public func requestSearchItems(with text: String) {
        // TODO: 검색 들어가야지 서제스트화면 숨겨짐
    }
}

// MARK: - IntegratedSearchViewModelImple Interactor + select suggest

extension IntegratedSearchViewModelImple {
    
    public func suggestQuery(didSelect searchQuery: String) {
        self.requestSearchItems(with: searchQuery)
    }
}


// MARK: - IntegratedSearchViewModelImple Presenter

extension IntegratedSearchViewModelImple {
    
}
