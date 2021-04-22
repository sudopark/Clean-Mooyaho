//
//  Scenable.swift
//  BreadRoadApp
//
//  Created by ParkHyunsoo on 2021/04/22.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit


public protocol Scenable: UIViewController { }


// scene은 화면을 추상 + 디펜던시 정보 포함

public enum Scene {
    
    public struct MainTabDependency {
        
        public let subScenes: [Scene.Main]
        
        public init(subScenes: Scene.Main...) {
            self.subScenes = subScenes
        }
        
        public init(subScenes: [Scene.Main]) {
            self.subScenes = subScenes
        }
    }
    
    case launching
    case mainTab(MainTabDependency)
}


// MARK: Scene - Main Tab

extension Scene {
    
    public enum Main {
        case empty
    }
}
