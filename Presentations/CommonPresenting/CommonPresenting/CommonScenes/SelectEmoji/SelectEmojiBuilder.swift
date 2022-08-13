//
//  
//  SelectEmojiBuilder.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/13.
//
//  CommonPresenting
//
//  Created sudo.park on 2021/11/13.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit


// MARK: - Builder + DependencyInjector Extension

@MainActor
public protocol SelectEmojiSceneBuilable {
    
    func makeSelectEmojiScene(listener: SelectEmojiSceneListenable?) -> SelectEmojiScene
}
