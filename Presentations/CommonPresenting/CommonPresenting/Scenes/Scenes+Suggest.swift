//
//  Scenes+Suggest.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/23.
//

import Foundation


// MARK: - IntegratedSearchScene Interactable & Listenable

public protocol IntegratedSearchSceneInteractable: AnyObject {
    
    func requestSuggest(with text: String)
    
    func requestSearchItems(with text: String)
}

public protocol IntegratedSearchSceneListenable: AnyObject { }


// MARK: - IntegratedSearchScene

public protocol IntegratedSearchScene: Scenable {
    
    var interactor: IntegratedSearchSceneInteractable? { get }
}
