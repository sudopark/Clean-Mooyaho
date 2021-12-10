//
//  DependencyInjector+SuggestScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import SuggestScene


// MARK: - suggest

extension DependencyInjector: IntegratedSearchSceneBuilable {
    
    private var suggestQueryUSecase: SuggestQueryUsecase & SuggestableQuerySyncUsecase {
        return SuggestQueryUsecaseImple(suggestQueryEngine: self.suggestQueryEngine,
                                        searchRepository: self.appReposiotry)
    }
    
    public func makeIntegratedSearchScene(listener: IntegratedSearchSceneListenable?,
                                          readCollectionMainInteractor: ReadCollectionMainSceneInteractable?) -> IntegratedSearchScene {
        let router = IntegratedSearchRouter(nextSceneBuilders: self)
        
        let suggestUsecase = self.suggestQueryUSecase
        router.suggestQueryUsecase = suggestUsecase
        
        let searchUsecase = IntegratedSearchUsecaseImple(suggestQuerySyncUsecase: suggestUsecase,
                                                         searchRepository: self.appReposiotry)
        let viewModel = IntegratedSearchViewModelImple(searchUsecase: searchUsecase,
                                                       categoryUsecase: self.categoryUsecase,
                                                       router: router,
                                                       listener: listener,
                                                       readCollectionMainInteractor: readCollectionMainInteractor)
        let viewController = IntegratedSearchViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: SuggestQuerySceneBuilable {
    
    public func makeSuggestQueryScene(suggestQueryUsecase: SuggestQueryUsecase,
                                      listener: SuggestQuerySceneListenable?) -> SuggestQueryScene {
        let router = SuggestQueryRouter(nextSceneBuilders: self)
        let viewModel = SuggestQueryViewModelImple(suggestQueryUsecase: suggestQueryUsecase,
                                                   router: router,
                                                   listener: listener)
        let viewController = SuggestQueryViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}


extension DependencyInjector: SuggestReadSceneBuilable {
    
    public func makeSuggestReadScene(
        listener: SuggestReadSceneListenable?,
        readCollectionMainInteractor: ReadCollectionMainSceneInteractable?
    ) -> SuggestReadScene {
        let router = SuggestReadRouter(nextSceneBuilders: self)
        
        let viewModel = SuggestReadViewModelImple (
            readItemUsecase: self.readItemUsecase,
            categoriesUsecase: self.categoryUsecase,
            router: router,
            listener: listener,
            readCollectionMainInteractor: readCollectionMainInteractor
        )
        let viewController = SuggestReadViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
