//
//  RepositoryImple+LinkPreview.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol LinkPreviewrepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var previewRemote: LinkPreviewRemote { get }
    var previewCache: LinkPreviewCacheStorage { get }
}


extension LinkPreviewRepository where Self: LinkPreviewrepositoryDefImpleDependency {
    
    
    public func loadLinkPreview(_ url: String) -> Maybe<LinkPreview> {
        let fetchCache = self.previewCache.fetchPreview(url)
        let useCacheOrLoadPreview: (LinkPreview?) -> Maybe<LinkPreview>
        useCacheOrLoadPreview = { [weak self] preview in
            guard let self = self else { return .empty() }
            return preview.map{ .just($0) } ?? self.loadPreviewFromRemoteAndUpdateCache(url)
        }
        return fetchCache
            .catchAndReturn(nil)
            .flatMap(useCacheOrLoadPreview)
    }
    
    private func loadPreviewFromRemoteAndUpdateCache(_ url: String) -> Maybe<LinkPreview> {
        
        let updateCache: (LinkPreview) -> Void = { [weak self] preview in
            guard let self = self else { return }
            self.previewCache.saveLinkPreview(for: url, preview: preview)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        return self.previewRemote.requestLoadPreview(url)
            .do(onNext: updateCache)
    }
}
