//
//  
//  SettingMainRouter.swift
//  SettingScene
//
//  Created by sudo.park on 2021/11/11.
//
//  SettingScene
//
//  Created sudo.park on 2021/11/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import CommonPresenting


// MARK: - Routing

public protocol SettingMainRouting: Routing {
    
    func editProfile()
    
    func manageAccount()
    
    func requestSignIn()
    
    func editItemsCategory()
    
    func resumeUserDataMigration()
    
    func changeDefaultRemindTime()
    
    func showScheduleReminds()
}

// MARK: - Routers

// TODO: compose next Scene Builders protocol
public typealias SettingMainRouterBuildables = EditProfileSceneBuilable & SignInSceneBuilable

public final class SettingMainRouter: Router<SettingMainRouterBuildables>, SettingMainRouting { }


extension SettingMainRouter {
    
    // SettingMainRouting implements
    private var currentInteractor: SettingMainSceneInteractable? {
        return (self.currentScene as? SettingMainScene)?.interactor
    }
    
    public func editProfile() {
        guard let next = self.nextScenesBuilder?.makeEditProfileScene() else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func manageAccount() {
        
    }
    
    public func requestSignIn() {
        guard let next = self.nextScenesBuilder?.makeSignInScene(nil) else {
            return
        }
        self.currentScene?.present(next, animated: true, completion: nil)
    }
    
    public func editItemsCategory() {
        
    }
    
    public func resumeUserDataMigration() {
        
    }
    
    public func changeDefaultRemindTime() {
        
    }
    
    public func showScheduleReminds() {
        
    }
}
