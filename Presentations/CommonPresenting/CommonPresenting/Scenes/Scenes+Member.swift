//
//  Scenes+Member.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/06/04.
//

import Foundation


import RxSwift


// MARK: - SignInScene

public protocol SignInScenePresenter {
    
    var signedIn: Observable<Void> { get }
}

public protocol SignInScene: Scenable, PangestureDismissableScene {
    
    var presenter: SignInScenePresenter? { get }
}

public protocol SignInSceneBuilable {
    
    func makeSignInScene() -> SignInScene
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
