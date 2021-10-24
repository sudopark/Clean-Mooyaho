//
//  
//  LinkMemoBuilder.swift
//  ViewerScene
//
//  Created by sudo.park on 2021/10/24.
//
//  ViewerScene
//
//  Created sudo.park on 2021/10/24.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol LinkMemoSceneBuilable {
    
    func makeLinkMemoScene(memo: ReadLinkMemo, listener: LinkMemoSceneListenable?) -> LinkMemoScene
}
