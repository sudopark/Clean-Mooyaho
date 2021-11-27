//
//  Scenes+Suggest.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/11/23.
//

import UIKit


// MARK: - IntegratedSearchScene Interactable & Listenable

public protocol IntegratedSearchSceneInteractable: SuggestQuerySceneListenable, InnerWebViewSceneListenable {
    
    func requestSuggest(with text: String)
    
    func requestSearchItems(with text: String)
}

public protocol IntegratedSearchSceneListenable: AnyObject {
    
    func integratedSearch(didUpdateSearching: Bool)
    
    func finishIntegratedSearch(_ completed: @escaping () -> Void)
}


// MARK: - IntegratedSearchScene

public protocol IntegratedSearchScene: Scenable {
    
    var interactor: IntegratedSearchSceneInteractable? { get }
    
    var suggestSceneContainer: UIView { get }
}


// MARK: - SuggestQueryScene Interactable & Listenable

public protocol SuggestQuerySceneInteractable: AnyObject {
    
    func suggest(with text: String)
}

public protocol SuggestQuerySceneListenable: AnyObject {
    
    func suggestQuery(didSelect searchQuery: String)
}


// MARK: - SuggestQueryScene

public protocol SuggestQueryScene: Scenable {
    
    var interactor: SuggestQuerySceneInteractable? { get }
}


// MARK: - SuggestReadScene Interactable & Listenable

public protocol SuggestReadSceneInteractable: AnyObject { }

public protocol SuggestReadSceneListenable: AnyObject { }


// MARK: - SuggestReadScene

public protocol SuggestReadScene: Scenable {
    
    var interactor: SuggestReadSceneInteractable? { get }
}
