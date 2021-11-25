//
//  
//  SuggestQueryBuilder.swift
//  SuggestScene
//
//  Created by sudo.park on 2021/11/23.
//
//  SuggestScene
//
//  Created sudo.park on 2021/11/23.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol SuggestQuerySceneBuilable {
    
    func makeSuggestQueryScene(suggestQueryUsecase: SuggestQueryUsecase,
                               listener: SuggestQuerySceneListenable?) -> SuggestQueryScene
}
