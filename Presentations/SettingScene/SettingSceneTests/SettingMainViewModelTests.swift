//
//  SettingMainViewModelTests.swift
//  SettingSceneTests
//
//  Created by sudo.park on 2021/11/11.
//

import XCTest

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting
import UnitTestHelpKit
import UsecaseDoubles

@testable import SettingScene


class SettingMainViewModelTests: BaseTestCase, WaitObservableEvents {
    
    var disposeBag: DisposeBag!
    private var routerAndListener: SpyRouterAndListenable!
    
    private var spyRouter: SpyRouterAndListenable {
        return self.routerAndListener
    }
    private var spyListener: SpyRouterAndListenable {
        return self.routerAndListener
    }
    
    private var stubMemberUsecase: BaseStubMemberUsecase!
    
    override func setUpWithError() throws {
        self.disposeBag = .init()
        self.routerAndListener = .init()
    }
    
    override func tearDownWithError() throws {
        self.disposeBag = nil
        self.routerAndListener = nil
        self.stubMemberUsecase = nil
    }
    
    private func makeViewModel(with currentMember: Member?) -> SettingMainViewModel {
        
        let scenario = BaseStubMemberUsecase.Scenario()
            |> \.currentMember .~ currentMember
        let stubMemberUsecase = BaseStubMemberUsecase(scenario: scenario)
        self.stubMemberUsecase = stubMemberUsecase
        
        return SettingMainViewModelImple(appID: "dummy",
                                         memberUsecase: stubMemberUsecase,
                                         deviceInfoService: StubDeviceInfoService(),
                                         router: self.spyRouter,
                                         listener: self.spyListener)
    }
}

extension SettingMainViewModelTests {
    
    private typealias Section = SettingMainViewModelImple.Section
    private typealias Item = SettingMainViewModelImple.Item
    
    func testViewModel_itemsWhenSignOut() {
        // given
        let expect = expectation(description: "로그아웃 상태에서 섹션 구성")
        let viewModel = self.makeViewModel(with: nil)
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections) {
            viewModel.refresh()
        }
        
        // then
        let accountSection = sections?.first(where: { $0.sectionID == Section.account.rawValue })
        let accountSectionItemIDs = accountSection?.cellViewModels.map { $0.itemID }
        let itemSection = sections?.first(where: { $0.sectionID == Section.items.rawValue })
        let itemSectionItemIDs = itemSection?.cellViewModels.map { $0.itemID }
        let serviceSection = sections?.first(where: { $0.sectionID == Section.service.rawValue })
        let serviceSectionItemIDs = serviceSection?.cellViewModels.map { $0.itemID }
        XCTAssertEqual(accountSectionItemIDs, [Item.signIn.typeName])
        XCTAssertEqual(itemSectionItemIDs, [Item.editCategories.typeName, Item.userDataMigration.typeName])
        XCTAssertEqual(serviceSectionItemIDs, [
            Item.appVersion("").typeName, Item.feedback.typeName, Item.sourceCode.typeName
        ])
    }
    
    func testViewModel_itemsWhenSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 섹션 구성")
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections, skip: 1) {
            viewModel.refresh()
        }
        
        // then
        let accountSection = sections?.first(where: { $0.sectionID == Section.account.rawValue })
        let accountSectionItemIDs = accountSection?.cellViewModels.map { $0.itemID }
        let itemSection = sections?.first(where: { $0.sectionID == Section.items.rawValue })
        let itemSectionItemIDs = itemSection?.cellViewModels.map { $0.itemID }
        let serviceSection = sections?.first(where: { $0.sectionID == Section.service.rawValue })
        let serviceSectionItemIDs = serviceSection?.cellViewModels.map { $0.itemID }
        XCTAssertEqual(accountSectionItemIDs, [Item.editProfile.typeName, Item.manageAccount.typeName])
        XCTAssertEqual(itemSectionItemIDs, [Item.editCategories.typeName, Item.userDataMigration.typeName])
        XCTAssertEqual(serviceSectionItemIDs, [
            Item.appVersion("").typeName, Item.feedback.typeName, Item.sourceCode.typeName
        ])
        
        let migrationCell = sections?.flatMap { $0.cellViewModels }
            .first(where: { $0.itemID == Item.userDataMigration.typeName })
        XCTAssertEqual(migrationCell?.isEnable, true)
    }
    
    func testViewModel_whenAfterSignIn_updateSections() {
        // given
        let expect = expectation(description: "로그인 이후에 account 섹션 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(with: nil)
        
        // when
        let sectionLists = self.waitElements(expect, for: viewModel.sections) {
            self.stubMemberUsecase.currentMemberMocking.onNext(Member(uid: "some", nickName: nil, icon: nil))
        }
        
        // then
        let memberSections = sectionLists.map { $0.filter{ $0.sectionID == Section.account.rawValue } }
        let (sectionSignOut, sectionSignIn) = (memberSections.first?.first, memberSections.last?.last)
        XCTAssertEqual(sectionSignOut?.cellViewModels.map { $0.itemID }, [Item.signIn.typeName])
        XCTAssertEqual(sectionSignIn?.cellViewModels.map { $0.itemID }, [Item.editProfile.typeName, Item.manageAccount.typeName])
    }
    
    func testViewModel_whenAfterSignOut_updateSections() {
        // given
        let expect = expectation(description: "로그인 이후에 account 섹션 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        let sectionLists = self.waitElements(expect, for: viewModel.sections, skip: 1) {
            self.stubMemberUsecase.currentMemberMocking.onNext(nil)
        }
        
        // then
        let memberSections = sectionLists.map { $0.filter{ $0.sectionID == Section.account.rawValue } }
        let (sectionSignOut, sectionSignIn) = (memberSections.last?.first, memberSections.first?.last)
        XCTAssertEqual(sectionSignOut?.cellViewModels.map { $0.itemID }, [Item.signIn.typeName])
        XCTAssertEqual(sectionSignIn?.cellViewModels.map { $0.itemID }, [Item.editProfile.typeName, Item.manageAccount.typeName])
    }
    
    func testViewModel_updateMigrationSection_bySignIn() {
        // given
        let expect = expectation(description: "로그인 여부에 따라 마이그레이션 활성화 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(with: nil)
        
        // when
        let migrationCellSource = viewModel.sections.map { $0.flatMap { $0.cellViewModels } }
            .map { $0.first(where: { $0.itemID == Item.userDataMigration.typeName }) }
        let cells = self.waitElements(expect, for: migrationCellSource) {
            self.stubMemberUsecase.currentMemberMocking.onNext(Member(uid: "some", nickName: nil, icon: nil))
            self.stubMemberUsecase.currentMemberMocking.onNext(nil)
        }
        
        // then
        let isEnables = cells.map { $0?.isEnable }
        XCTAssertEqual(isEnables, [false, true, false])
    }
}

extension SettingMainViewModelTests {
    
    func testViewModel_requestRouteToEditProfile() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.editProfile.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToEditProfile, true)
    }
    
    func testViewModel_requestRouteToManageAccount() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.manageAccount.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToManageAccount, true)
    }
    
    func testViewModel_requestRouteToSignIn() {
        // given
        let viewModel = self.makeViewModel(with: nil)
        
        // when
        viewModel.selectItem(Item.signIn.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didMovetoSignIn, true)
    }
    
    func testViewModel_requestRouteToEditCategory() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.editCategories.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToEditCategory, true)
    }
    
    func testViewModel_requestRouteToUserDataMigration() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.userDataMigration.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToUserDataMigration, true)
    }
    
    func testViewModel_openAppStore() {
        // given
        let viewModel = self.makeViewModel(with: Member.init(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.appVersion("some").typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didOpenURLPath, "http://itunes.apple.com/app/iddummy")
    }
    
    func testViewModel_openSourceCode() {
        // given
        let viewModel = self.makeViewModel(with: Member.init(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.sourceCode.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didOpenURLPath, "https://github.com/sudopark/Clean-Mooyaho")
    }
    
    func testViewMdoel_routeToEnterFeedback() {
        // given
        let viewModel = self.makeViewModel(with: Member.init(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.feedback.typeName)
        
        // then
        XCTAssertEqual(self.spyRouter.didRouteToEnterFeedback, true)
    }
}


extension SettingMainViewModelTests {
    
    class SpyRouterAndListenable: SettingMainRouting, SettingMainSceneListenable {
        
        var didMoveToEditProfile = false
        func editProfile() {
            self.didMoveToEditProfile = true
        }
        
        var didMoveToManageAccount = false
        func manageAccount() {
            self.didMoveToManageAccount = true
        }
        
        var didMovetoSignIn = false
        func requestSignIn() {
            self.didMovetoSignIn = true
        }
        
        var didMoveToEditCategory = false
        func editItemsCategory() {
            self.didMoveToEditCategory = true
        }
        
        var didMoveToUserDataMigration = false
        func resumeUserDataMigration(for userID: String) {
            self.didMoveToUserDataMigration = true
        }
        
        var didMoveToChangeDefaultRemindtime = false
        func changeDefaultRemindTime() {
            self.didMoveToChangeDefaultRemindtime = true
        }
        
        var didOpenURLPath: String?
        func openURL(_ path: String) {
            self.didOpenURLPath = path
        }
        
        var didRouteToEnterFeedback: Bool?
        func routeToEnterFeedback() {
            self.didRouteToEnterFeedback = true
        }
    }
    
    class StubDeviceInfoService: DeviceInfoService {
        
        func osVersion() -> String {
            return "os version"
        }
        
        func appVersion() -> String {
            return "1.0.0(0)"
        }
        
        func deviceModel() -> String {
            return "some"
        }
    }
}

