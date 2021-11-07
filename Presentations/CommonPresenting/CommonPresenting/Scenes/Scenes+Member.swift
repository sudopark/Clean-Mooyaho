//
//  Scenes+Member.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation


import RxSwift

import Domain


// MARK: - SignInScene

public protocol SignInSceneInteractable { }

public protocol SignInSceneListenable: AnyObject {
    
    func signIn(didCompleted member: Member)
}

public protocol SignInScene: Scenable, PangestureDismissableScene {
    
    var interactor: SignInSceneInteractable? { get }
}

public protocol SignInSceneBuilable {
    
    func makeSignInScene(_ listener: SignInSceneListenable?) -> SignInScene
}


// MARK: - EditProfileScene

public protocol EditProfileScenePresenter {
    
    var editCompleted: Observable<Void> { get }
}

public protocol EditProfileScene: Scenable {
    
    var presenrer: EditProfileScenePresenter? { get }
}

public protocol EditProfileSceneBuilable {
    
    func makeEditProfileScene() -> EditProfileScene
}
