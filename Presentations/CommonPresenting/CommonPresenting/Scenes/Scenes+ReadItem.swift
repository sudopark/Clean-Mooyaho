//
//  Scenes+ReadItem.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/09/19.
//

import Foundation

import RxSwift

import Domain


// MARK: - ReadCollectionScene

// MARK: - ReadCollectionScene Input & Output

public protocol ReadCollectionSceneInput { }

public protocol ReadCollectionSceneOutput { }


// MARK: - ReadCollectionScene

public protocol ReadCollectionScene: Scenable {
    
    var input: ReadCollectionSceneInput? { get }

    var output: ReadCollectionSceneOutput? { get }
}
