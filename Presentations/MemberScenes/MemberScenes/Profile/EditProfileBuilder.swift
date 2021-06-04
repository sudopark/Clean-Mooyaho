//
//  
//  EditProfileBuilder.swift
//  MemberScenes
//
//  Created by sudo.park on 2021/05/30.
//
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Builder + DI Container Extension


public protocol EditProfileSceneBuilable {
    
    func makeEditProfileScene() -> EditProfileScene
}
