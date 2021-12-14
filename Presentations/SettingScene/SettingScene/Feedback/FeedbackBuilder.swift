//
//  
//  FeedbackBuilder.swift
//  SettingScene
//
//  Created by sudo.park on 2021/12/15.
//
//  SettingScene
//
//  Created sudo.park on 2021/12/15.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol FeedbackSceneBuilable {
    
    func makeFeedbackScene(listener: FeedbackSceneListenable?) -> FeedbackScene
}
