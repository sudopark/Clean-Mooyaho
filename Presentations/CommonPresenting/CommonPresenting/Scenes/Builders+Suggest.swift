//
//  Builders+Suggest.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/23.
//

import Foundation


// MARK: - IntegratedSearchSceneBuilable

public protocol IntegratedSearchSceneBuilable {
    
    func makeIntegratedSearchScene(listener: IntegratedSearchSceneListenable?,
                                   readCollectionMainInteractor: ReadCollectionMainSceneInteractable?) -> IntegratedSearchScene
}

// MARK: - SuggestReadSceneBuilable

public protocol SuggestReadSceneBuilable {
    
    func makeSuggestReadScene(
        listener: SuggestReadSceneListenable?,
        readCollectionMainInteractor: ReadCollectionMainSceneInteractable?
    ) -> SuggestReadScene
}
