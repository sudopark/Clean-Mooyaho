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


// MARK: - EditProfileScene

public protocol EditProfileSceneInteractable: ImagePickerSceneListenable, SelectEmojiSceneListenable { }

public protocol EditProfileScene: Scenable {
    
    var interactor: EditProfileSceneInteractable? { get }
}


// MARK: - MemberProfileScene Interactable & Listenable

public protocol MemberProfileSceneInteractable { }

public protocol MemberProfileSceneListenable: AnyObject { }


// MARK: - MemberProfileScene

public protocol MemberProfileScene: Scenable {
    
    var interactor: MemberProfileSceneInteractable? { get }
}


// MARK: - RecoverAccountScene Interactable & Listenable

public protocol RecoverAccountSceneInteractable { }

public protocol RecoverAccountSceneListenable: AnyObject {
    
    func recoverAccount(didCompleted recoveredMember: Member)
}


// MARK: - RecoverAccountScene

public protocol RecoverAccountScene: Scenable {
    
    var interactor: RecoverAccountSceneInteractable? { get }
}
