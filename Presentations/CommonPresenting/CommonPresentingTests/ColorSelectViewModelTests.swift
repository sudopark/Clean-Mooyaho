//
//  ColorSelectViewModelTests.swift
//  CommonPresentingTests
//
//  Created by sudo.park on 2021/10/11.
//

import XCTest

import RxSwift

import Domain
import UnitTestHelpKit

import CommonPresenting


class ColorSelectViewModelTests: BaseTestCase, WaitObservableEvents, ColorSelectRouting, ColorSelectSceneListenable {
    
    var disposeBag: DisposeBag!
    var didClose: Bool?
    var didSelectedColor: String?
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.didClose = nil
        self.didSelectedColor = nil
    }
    
    func colorSelect(didSeelctColor hexCode: String) {
        self.didSelectedColor = hexCode
    }
    
    func closeScene(animated: Bool, completed: (() -> Void)?) {
        self.didClose = true
        completed?()
    }
    
    private func makeViewModel(startWith: String? = nil) -> ColorSelectViewModel {
        
        let colors = (0..<10).map { "c:\($0)" }
        return  ColorSelectViewModelImple(startWithSelect: startWith,
                                          colorSources: colors,
                                          router: self, listener: self)
    }
}


extension ColorSelectViewModelTests {
    
    func testViewModel_whenSelectColor_udpateList() {
        // given
        let expect = expectation(description: "선택에따라 리스트 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(startWith: "c:3")
        
        // when
        let cvms = self.waitElements(expect, for: viewModel.cellViewModels) {
            viewModel.selectColor("c:2")
            viewModel.selectColor("c:5")
        }
        
        // then
        let selecteds = cvms.map { $0.filter{ $0.isSelected }.map { $0.hextCode } }
        XCTAssertEqual(selecteds, [["c:3"], ["c:2"], ["c:5"]])
    }
    
    func testViewModel_confirmSelectColor() {
        // given
        let viewModel = self.makeViewModel()
        
        // when
        viewModel.selectColor("c:3")
        viewModel.confirmSelect()
        
        // then
        XCTAssertEqual(self.didClose, true)
        XCTAssertEqual(self.didSelectedColor, "c:3")
    }
}
