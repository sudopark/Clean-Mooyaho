//
//  MockSession.swift
//  FirebaseServiceTests
//
//  Created by sudo.park on 2021/05/08.
//

import Foundation

import RxSwift

import DataStore
import UnitTestHelpKit

@testable import FirebaseService


func readJsonAsData(_ fileName: String) -> Data? {
    
    let bundle = Bundle(for: MockSession.self)
    let fileURL = bundle.url(forResource: fileName, withExtension: ".json")
    let data = fileURL.flatMap{ try? Data(contentsOf: $0) }
    return data
}


class MockSession: HttpSession, Mocking {
    
    func requestData(path: String, method: HttpAPIMethods,
                     parameters: [String : Any],
                     header: [String : String]?) -> Maybe<HttpResponse> {
        self.verify(key: "requestData", with: [
            "path": path,
            "params": parameters,
            "header": header ?? [:]
        ])
        return self.resolve(key: "requestData") ?? .empty()
    }
}

class FakeHttpAPI: HttpAPI {
    
    let session: HttpSession
    init(session: HttpSession) {
        self.session = session
    }
}
