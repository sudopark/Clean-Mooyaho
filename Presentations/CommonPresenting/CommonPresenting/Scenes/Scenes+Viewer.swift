//
//  Scenes+Viewer.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import UIKit

import Domain


// MARK: - InnerWebViewScene Interactor & Listener

public protocol InnerWebViewSceneInteractable: Sendable, LinkMemoSceneListenable { }

public protocol InnerWebViewSceneListenable: Sendable, AnyObject {
    
    func innerWebView(reqeustJumpTo collectionID: String?)
}


// MARK: - InnerWebViewScene

public protocol InnerWebViewScene: Scenable {
    
    nonisolated var interactor: InnerWebViewSceneInteractable? { get }
}


// MARK: - LinkMemoScene Interactable & Listenable

public protocol LinkMemoSceneInteractable: Sendable { }

public protocol LinkMemoSceneListenable: Sendable, AnyObject {
    
    func linkMemo(didUpdated newVlaue: ReadLinkMemo)
    
    func linkMemo(didRemoved linkItemID: String)
}


// MARK: - LinkMemoScene

public protocol LinkMemoScene: Scenable {
    
    nonisolated var interactor: LinkMemoSceneInteractable? { get }
}
