//
//  LinkPreviewRepository.swift
//  Domain
//
//  Created by sudo.park on 2021/09/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol LinkPreviewRepository {
    
    func loadLinkPreview(_ url: String) -> Maybe<LinkPreview>
}
