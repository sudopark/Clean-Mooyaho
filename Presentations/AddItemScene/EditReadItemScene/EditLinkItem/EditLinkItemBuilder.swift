//
//  
//  EditLinkItemBuilder.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/03.
//
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/03.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public enum EditLinkItemCase {
    case makeNew( url: String)
    case edit(item: ReadLink)
}

public protocol EditLinkItemSceneBuilable {
    
    func makeEditLinkItemScene(_ editCase: EditLinkItemCase,
                               collectionID: String?,
                               completed: @escaping (ReadLink) -> Void) -> EditLinkItemScene
}
