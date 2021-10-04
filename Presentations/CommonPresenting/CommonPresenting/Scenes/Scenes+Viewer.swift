//
//  Scenes+Viewer.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/04.
//

import UIKit

import Domain


// MARK: - InnerWebViewScene Input & Output

public protocol InnerWebViewSceneInput { }

public protocol InnerWebViewSceneOutput { }


// MARK: - InnerWebViewScene

public protocol InnerWebViewScene: Scenable {
    
    var input: InnerWebViewSceneInput? { get }

    var output: InnerWebViewSceneOutput? { get }
}
