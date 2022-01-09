//
//  StubLinkPreviewRepository.swift
//  DomainTests
//
//  Created by sudo.park on 2021/09/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


class StubLinkPreviewRepository: LinkPreviewRepository {
    
    struct Scenario {
        var preview: Result<LinkPreview, Error> = .success(.dummy(0))
    }
    
    private let scenario: Scenario
    init(scenario: Scenario = Scenario()) {
        self.scenario = scenario
    }
    
    var previewLoadMocking: Maybe<LinkPreview>?
    
    func loadLinkPreview(_ url: String) -> Maybe<LinkPreview> {
        return self.previewLoadMocking ?? self.scenario.preview.asMaybe()
    }
}
