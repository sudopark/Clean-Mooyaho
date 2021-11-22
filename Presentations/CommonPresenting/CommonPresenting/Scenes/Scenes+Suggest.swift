//
//  Scenes+Suggest.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/23.
//

import Foundation


// MARK: - IntegratedSearchScene Interactable & Listenable

public protocol IntegratedSearchSceneInteractable { }

public protocol IntegratedSearchSceneListenable: AnyObject { }


// MARK: - IntegratedSearchScene

public protocol IntegratedSearchScene: Scenable {
    
    var interactor: IntegratedSearchSceneInteractable? { get }
}
