//
//  LinkPreviewRemoteImple.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import SwiftLinkPreview

import Domain


public final class LinkPreviewRemoteImple {
    
    private let previewEngine: SwiftLinkPreview
    
    
    public init() {
        self.previewEngine = SwiftLinkPreview(cache: DisabledCache.instance)
    }
}



extension LinkPreviewRemoteImple: LinkPreviewRemote {
    
    public func requestLoadPreview(_ url: String) -> Maybe<LinkPreview> {
        return Maybe.create { [weak self] callback in
            guard let self = self else { return Disposables.create() }
            
            guard let url = URL(string: url) else {
                let error = RemoteErrors.invalidRequest(url)
                callback(.error(error))
                return Disposables.create()
            }
            
            let previewLoaded: (Response) -> Void = { response in
                let preview = response.asLinkPreview()
                callback(.success(preview))
            }
            
            let loadPreviewFail: (Error) -> Void = { error in
                callback(.error(error))
            }
            
            let request = self.previewEngine.preview(url: url,
                                                     onSuccess: previewLoaded,
                                                     onError: loadPreviewFail)
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}

private extension Response {
    
    func asLinkPreview() -> LinkPreview {
        
        return LinkPreview(title: self.title,
                           description: self.description,
                           mainImageURL: self.image ?? self.images?.first,
                           iconURL: self.icon)
    }
}
