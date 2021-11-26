//
//  Builders+Suggest.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/23.
//

import Foundation


// MARK: - Builder + DependencyInjector Extension

public protocol IntegratedSearchSceneBuilable {
    
    func makeIntegratedSearchScene(listener: IntegratedSearchSceneListenable?,
                                   readCollectionMainInteractor: ReadCollectionMainSceneInteractable?) -> IntegratedSearchScene
}
