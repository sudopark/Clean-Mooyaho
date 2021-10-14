//
//  EditItemsCustomOrderViewModelImpleTests.swift
//  EditReadItemSceneTests
//
//  Created by sudo.park on 2021/10/15.
//

import XCTest

import RxSwift

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

import EditReadItemScene


class EditItemsCustomOrderViewModelImpleTests: BaseTestCase, WaitObservableEvents, EditItemsCustomOrderRouting, EditItemsCustomOrderSceneListenable {
    
    var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        
    }
    
    override func tearDownWithError() throws {
        
    }
    
    private func makeViewModel() -> EditItemsCustomOrderViewModel {
        
        return EditItemsCustomOrderViewModelImple(router: self, listener: self)
    }
}


extension EditItemsCustomOrderViewModelImpleTests {
    
    // 최초에 커스텀 오더로 리스트 출력
    
    // 콜렉션은 콜렉션끼리만 순서 교환 가능
    
    // 아이템은 아이템 끼리만 순서교환 가능
}

extension EditItemsCustomOrderViewModelImpleTests {
    
    // 저장완료 이후에 화면닫고 외부로 이벤트 전파(뷰 유스케이스)
    
    // 저장실패시 알림
}
