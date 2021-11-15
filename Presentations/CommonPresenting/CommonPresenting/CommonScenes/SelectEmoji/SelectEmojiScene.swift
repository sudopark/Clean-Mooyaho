//
//  SelectEmojiScene.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/11/13.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa


// MARK: - SelectEmojiScene Interactable & Listenable

public protocol SelectEmojiSceneListenable: AnyObject {
    
    func selectEmoji(didSelect emoji: String)
}


// MARK: - SelectEmojiScene

public protocol SelectEmojiScene: Scenable { }
