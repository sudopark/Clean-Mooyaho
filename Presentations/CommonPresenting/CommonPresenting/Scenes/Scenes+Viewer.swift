//
//  Scenes+Viewer.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import UIKit

import Domain


// MARK: - InnerWebViewScene Interactor & Listener

public protocol InnerWebViewSceneInteractable { }

public protocol InnerWebViewSceneListenable { }


// MARK: - InnerWebViewScene

public protocol InnerWebViewScene: Scenable {
    
    var interactor: InnerWebViewSceneInteractable? { get }
}
