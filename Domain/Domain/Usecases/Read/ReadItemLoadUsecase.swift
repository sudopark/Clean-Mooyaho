//
//  ReadItemLoadUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/09/13.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadLinkPreviewLoadUsecase {
    
    func loadLinkPreview(_ url: String) -> Observable<LinkPreview>
}


public protocol ReadItemLoadUsecase: ReadLinkPreviewLoadUsecase {
    
    func loadMyItems() -> Observable<[ReadItem]>
    
    func loadCollectionInfo(_ collectionID: String) -> Observable<ReadCollection>
    
    func loadCollectionItems(_ collectionID: String) -> Observable<[ReadItem]>
    
    func loadReadLink(_ linkID: String) -> Observable<ReadLink>
    
    func suggestNextReadItem(size: Int) -> Maybe<[ReadItem]>
    
    func continueReadingLinks() -> Observable<[ReadLink]>
    
    func loadReadItems(for itemIDs: [String]) -> Maybe<[ReadItem]>
}
