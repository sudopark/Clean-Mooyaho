//
//  StubHttpRemote.swift
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
    
    let bundle = Bundle(for: StubSession.self)
    let fileURL = bundle.url(forResource: fileName, withExtension: ".json")
    let data = fileURL.flatMap{ try? Data(contentsOf: $0) }
    return data
}


class StubSession: HttpSession, Stubbable {
    
    func requestData(path: String, method: HttpAPIMethods,
                     parameters: [String : Any],
                     header: [String : String]?) -> Maybe<HttpResponse> {
        return self.resolve(key: "requestData") ?? .empty()
    }
}

class FakeHttpRemote: HttpRemote {
    
    let session: HttpSession
    init(session: HttpSession) {
        self.session = session
    }
}
