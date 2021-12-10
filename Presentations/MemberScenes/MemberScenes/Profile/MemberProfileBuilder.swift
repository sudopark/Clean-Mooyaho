//
//  
//  MemberProfileBuilder.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/12/11.
//
//  MemberScenes
//
//  Created sudo.park on 2021/12/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DependencyInjector Extension

public protocol MemberProfileSceneBuilable {
    
    func makeMemberProfileScene(listener: MemberProfileSceneListenable?) -> MemberProfileScene
}
