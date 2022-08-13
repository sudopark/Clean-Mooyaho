//
//  
//  EnterLinkURLBuilder.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/02.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/02.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol EnterLinkURLSceneBuilable {
    
    func makeEnterLinkURLScene(startWith: String?,
                               _ entered: @escaping (String) -> Void) -> EnterLinkURLScene
}
