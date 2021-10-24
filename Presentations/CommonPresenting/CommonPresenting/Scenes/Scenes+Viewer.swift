//
//  Scenes+Viewer.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import UIKit

import Domain


// MARK: - InnerWebViewScene Interactor & Listener

public protocol InnerWebViewSceneInteractable: LinkMemoSceneListenable { }

public protocol InnerWebViewSceneListenable { }


// MARK: - InnerWebViewScene

public protocol InnerWebViewScene: Scenable {
    
    var interactor: InnerWebViewSceneInteractable? { get }
}


// MARK: - LinkMemoScene Interactable & Listenable

public protocol LinkMemoSceneInteractable { }

public protocol LinkMemoSceneListenable: AnyObject {
    
    func linkMemo(didUpdated newVlaue: ReadLinkMemo)
    
    func linkMemo(didRemoved linkItemID: String)
}


// MARK: - LinkMemoScene

public protocol LinkMemoScene: Scenable, PangestureDismissableScene {
    
    var interactor: LinkMemoSceneInteractable? { get }
}
