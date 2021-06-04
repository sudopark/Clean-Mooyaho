//
//  
//  SuggestPlaceBuilder.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/05/28.
//
//  PlaceScenes
//
//  Created sudo.park on 2021/05/28.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension

public protocol SuggestPlaceSceneBuilable {
    
    func makeSuggestPlaceScene() -> SuggestPlaceScene
}
