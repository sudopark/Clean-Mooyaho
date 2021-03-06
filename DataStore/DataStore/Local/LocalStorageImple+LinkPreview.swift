//
//  LocalStorage+LinkPreview.swift
//  DataStore
//
//  Created by sudo.park on 2021/09/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


extension LocalStorageImple {
    
    
    public func fetchPreview(_ url: String) -> Maybe<LinkPreview?> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.fetchLinkPreview(url)
    }
    
    public func saveLinkPreview(for url: String, preview: LinkPreview) -> Maybe<Void> {
        guard let storage = self.dataModelStorage else {
            return .error(LocalErrors.localStorageNotReady)
        }
        return storage.saveLinkPreview(for: url, preview: preview)
    }
}
