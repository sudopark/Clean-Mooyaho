//
//  DependencyInjector+ViewerScenes.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/12/11.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import UIKit

import Domain
import CommonPresenting
import ViewerScene


// MARK: - ViewerScenes

extension DependencyInjector: InnerWebViewSceneBuilable {
    
    public func makeInnerWebViewScene(link: ReadLink,
                                      isEditable: Bool,
                                      isJumpable: Bool,
                                      listener: InnerWebViewSceneListenable?) -> InnerWebViewScene {
        let router = InnerWebViewRouter(nextSceneBuilders: self)
        let viewModel = InnerWebViewViewModelImple(itemSource: .item(link),
                                                   isEditable: isEditable,
                                                   isJumpable: isJumpable,
                                                   readItemUsecase: self.readItemUsecase,
                                                   readingOptionUsecase: self.readingOptionUsecase,
                                                   memoUsecase: self.memoUsecase,
                                                   router: router,
                                                   clipboardService: UIPasteboard.general,
                                                   listener: listener)
        let viewController = InnerWebViewViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
    
    func makeInnerWebViewScene(linkID: String,
                               isEditable: Bool,
                               isJumpable: Bool,
                               listener: InnerWebViewSceneListenable?) -> InnerWebViewScene {
        let router = InnerWebViewRouter(nextSceneBuilders: self)
        let viewModel = InnerWebViewViewModelImple(itemSource: .itemID(linkID),
                                                   isEditable: isEditable,
                                                   isJumpable: isJumpable,
                                                   readItemUsecase: self.readItemUsecase,
                                                   readingOptionUsecase: self.readingOptionUsecase,
                                                   memoUsecase: self.memoUsecase,
                                                   router: router,
                                                   clipboardService: UIPasteboard.general,
                                                   listener: listener)
        let viewController = InnerWebViewViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}

extension DependencyInjector: LinkMemoSceneBuilable {
    
    public func makeLinkMemoScene(memo: ReadLinkMemo, listener: LinkMemoSceneListenable?) -> LinkMemoScene {
        let router = LinkMemoRouter(nextSceneBuilders: self)
        let viewModel = LinkMemoViewModelImple(memo: memo,
                                               memoUsecase: self.memoUsecase,
                                               router: router, listener: listener)
        let viewController = LinkMemoViewController(viewModel: viewModel)
        router.currentScene = viewController
        return viewController
    }
}
