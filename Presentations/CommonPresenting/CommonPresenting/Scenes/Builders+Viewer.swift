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
    
    func makeInnerWebViewScene(link: ReadLink, isEditable: Bool) -> InnerWebViewScene
}
