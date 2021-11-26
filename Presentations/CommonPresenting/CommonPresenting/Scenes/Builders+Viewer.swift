//
//  Builders+Viewer.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import UIKit

import Domain


// MARK: - Builder + DependencyInjector Extension

public protocol InnerWebViewSceneBuilable {
    
    func makeInnerWebViewScene(link: ReadLink,
                               isEditable: Bool,
                               listener: InnerWebViewSceneListenable?) -> InnerWebViewScene
    
    func makeInnerWebViewScene(linkID: String,
                               isEditable: Bool,
                               isJumpable: Bool,
                               listener: InnerWebViewSceneListenable?) -> InnerWebViewScene
}
