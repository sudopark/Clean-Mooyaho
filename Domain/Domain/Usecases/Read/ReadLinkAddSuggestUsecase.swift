//
//  ReadLinkAddSuggestUsecase.swift
//  Domain
//
//  Created by sudo.park on 2021/10/31.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol ReadLinkAddSuggestUsecase: Sendable {
    
    func loadSuggestAddNewItemByURLExists() -> Maybe<String?>
}
