//
//  Scenes+Suggest.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/23.
//

import UIKit


// MARK: - IntegratedSearchScene Interactable & Listenable

public protocol IntegratedSearchSceneInteractable: Sendable, SuggestQuerySceneListenable, InnerWebViewSceneListenable {
    
    func requestSuggest(with text: String)
    
    func requestSearchItems(with text: String)
}

public protocol IntegratedSearchSceneListenable: Sendable, AnyObject {
    
    func integratedSearch(didUpdateSearching: Bool)
    
    func finishIntegratedSearch(_ completed: @Sendable @escaping () -> Void)
}


// MARK: - IntegratedSearchScene

public protocol IntegratedSearchScene: Scenable {
    
    nonisolated var interactor: IntegratedSearchSceneInteractable? { get }
    
    var suggestSceneContainer: UIView { get }
}


// MARK: - SuggestQueryScene Interactable & Listenable

public protocol SuggestQuerySceneInteractable: Sendable, AnyObject {
    
    func suggest(with text: String)
}

public protocol SuggestQuerySceneListenable: Sendable, AnyObject {
    
    func suggestQuery(didSelect searchQuery: String)
}


// MARK: - SuggestQueryScene

public protocol SuggestQueryScene: Scenable {
    
    nonisolated var interactor: SuggestQuerySceneInteractable? { get }
}


// MARK: - SuggestReadScene Interactable & Listenable

public protocol SuggestReadSceneInteractable: Sendable, InnerWebViewSceneListenable & FavoriteItemsSceneListenable {
    
    func refresh()
}

public protocol SuggestReadSceneListenable: Sendable, AnyObject {
    
    func finishSuggesting(_ completed: @escaping @Sendable () -> Void)
}


// MARK: - SuggestReadScene

public protocol SuggestReadScene: Scenable {
    
    nonisolated var interactor: SuggestReadSceneInteractable? { get }
}
