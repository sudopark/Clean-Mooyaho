//
//  LocalStorageTests+LinkPreview.swift
//  DataStoreTests
//
//  Created by sudo.park on 2021/09/26.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import UnitTestHelpKit

import DataStore


class LocalStorageTests_LinkPreview: BaseLocalStorageTests {
    
    private var dummyPreview: LinkPreview {
        return LinkPreview(title: "dummy title",
                           description: "dummy description",
                           mainImageURL: "https://www.some.comc.image/?aidsd=asfsfiifasf",
                           iconURL: "https://www.some.comc.image/?aidsd=asfsfiifasf")
    }
    
    private var dummyURL: String {
        return "https://www.asd.saind/sijfdf?q4342&asfkaklf"
    }
    
    func testStorage_saveAndLoadPreview() {
        // given
        let expect = expectation(description: "link preview 저장하고 로드")
        
        // when
        let save = self.local.saveLinkPreview(for: self.dummyURL, preview: self.dummyPreview)
        let load = self.local.fetchPreview(self.dummyURL)
        let saveAndLoad = save.flatMap { load }
        let preview = self.waitFirstElement(expect, for: saveAndLoad.asObservable())
        
        // then
        XCTAssertNotNil(preview)
    }
}
