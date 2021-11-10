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
    
    private func makeViewModel(with currentMember: Member?,
                               remindTime: RemindTime = .default) -> SettingMainViewModel {
        
        let scenario = BaseStubMemberUsecase.Scenario()
            |> \.currentMember .~ currentMember
        let stubMemberUsecase = BaseStubMemberUsecase(scenario: scenario)
        self.stubMemberUsecase = stubMemberUsecase
        
        let remindScenario = StubReadRemindUsecase.Scenario()
            |> \.defaultRemindtime .~ remindTime
        let stubRemindUsecase = StubReadRemindUsecase(scenario: remindScenario)
        
        return SettingMainViewModelImple(memberUsecase: stubMemberUsecase,
                                         remindOptionUsecase: stubRemindUsecase,
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
        let remindSection = sections?.first(where: { $0.sectionID == Section.remind.rawValue })
        let remindSectionItemIDs = remindSection?.cellViewModels.map { $0.itemID }
        XCTAssertEqual(accountSectionItemIDs, [Item.signIn.identifier])
        XCTAssertEqual(itemSectionItemIDs, [Item.editCategories.identifier, Item.userDataMigration.identifier])
        XCTAssertEqual(remindSectionItemIDs, [Item.defaultRemidTime(RemindTime.default).identifier, Item.scheduledReminders.identifier])
    }
    
    func testViewModel_itemsWhenSignIn() {
        // given
        let expect = expectation(description: "로그인 상태에서 섹션 구성")
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        let sections = self.waitFirstElement(expect, for: viewModel.sections) {
            viewModel.refresh()
        }
        
        // then
        let accountSection = sections?.first(where: { $0.sectionID == Section.account.rawValue })
        let accountSectionItemIDs = accountSection?.cellViewModels.map { $0.itemID }
        let itemSection = sections?.first(where: { $0.sectionID == Section.items.rawValue })
        let itemSectionItemIDs = itemSection?.cellViewModels.map { $0.itemID }
        let remindSection = sections?.first(where: { $0.sectionID == Section.remind.rawValue })
        let remindSectionItemIDs = remindSection?.cellViewModels.map { $0.itemID }
        XCTAssertEqual(accountSectionItemIDs, [Item.editProfile.identifier, Item.manageAccount.identifier])
        XCTAssertEqual(itemSectionItemIDs, [Item.editCategories.identifier, Item.userDataMigration.identifier])
        XCTAssertEqual(remindSectionItemIDs, [Item.defaultRemidTime(RemindTime.default).identifier, Item.scheduledReminders.identifier])
        
        let migrationCell = sections?.flatMap { $0.cellViewModels }
            .first(where: { $0.itemID == Item.userDataMigration.identifier })
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
        XCTAssertEqual(sectionSignOut?.cellViewModels.map { $0.itemID }, [Item.signIn.identifier])
        XCTAssertEqual(sectionSignIn?.cellViewModels.map { $0.itemID }, [Item.editProfile.identifier, Item.manageAccount.identifier])
    }
    
    func testViewModel_whenAfterSignOut_updateSections() {
        // given
        let expect = expectation(description: "로그인 이후에 account 섹션 업데이트")
        expect.expectedFulfillmentCount = 2
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        let sectionLists = self.waitElements(expect, for: viewModel.sections) {
            self.stubMemberUsecase.currentMemberMocking.onNext(nil)
        }
        
        // then
        let memberSections = sectionLists.map { $0.filter{ $0.sectionID == Section.account.rawValue } }
        let (sectionSignOut, sectionSignIn) = (memberSections.last?.first, memberSections.first?.last)
        XCTAssertEqual(sectionSignOut?.cellViewModels.map { $0.itemID }, [Item.signIn.identifier])
        XCTAssertEqual(sectionSignIn?.cellViewModels.map { $0.itemID }, [Item.editProfile.identifier, Item.manageAccount.identifier])
    }
    
    func testViewModel_updateMigrationSection_bySignIn() {
        // given
        let expect = expectation(description: "로그인 여부에 따라 마이그레이션 활성화 업데이트")
        expect.expectedFulfillmentCount = 3
        let viewModel = self.makeViewModel(with: nil)
        
        // when
        let migrationCellSource = viewModel.sections.map { $0.flatMap { $0.cellViewModels } }
            .map { $0.first(where: { $0.itemID == Item.userDataMigration.identifier }) }
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
    
    func testViewModel_showDefaultRemindTime() {
        // given
        let expect = expectation(description: "설정된 remind time 출력")
        let viewmodel = self.makeViewModel(with: nil, remindTime: RemindTime(hour: 13, minute: 30))
        
        // when
        let sections = self.waitFirstElement(expect, for: viewmodel.sections, skip: 1) {
            viewmodel.refresh()
        }
        
        // then
        let remindCell = sections?.flatMap { $0.cellViewModels }
            .first(where: { $0.itemID == Item.defaultRemidTime(.default).identifier })
        if case let .accentValue(value) = remindCell?.accessory, value == "PM 01:30" {
            
        } else {
            XCTFail("기대하는 값이 아님")
        }
    }
    
    // TODO: refresh remind time after update
}

extension SettingMainViewModelTests {
    
    func testViewModel_requestRouteToEditProfile() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.editProfile.identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToEditProfile, true)
    }
    
    func testViewModel_requestRouteToManageAccount() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.manageAccount.identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToManageAccount, true)
    }
    
    func testViewModel_requestRouteToSignIn() {
        // given
        let viewModel = self.makeViewModel(with: nil)
        
        // when
        viewModel.selectItem(Item.signIn.identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMovetoSignIn, true)
    }
    
    func testViewModel_requestRouteToEditCategory() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.editCategories.identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToEditCategory, true)
    }
    
    func testViewModel_requestRouteToUserDataMigration() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.userDataMigration.identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToUserDataMigration, true)
    }
    
    func testViewModel_requestRouteToDefaultRemindTime() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.defaultRemidTime(.default).identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToChangeDefaultRemindtime, true)
    }
    
    func testViewModel_requestRouteToShowSceheduleTime() {
        // given
        let viewModel = self.makeViewModel(with: Member(uid: "some", nickName: nil, icon: nil))
        
        // when
        viewModel.selectItem(Item.scheduledReminders.identifier)
        
        // then
        XCTAssertEqual(self.spyRouter.didMoveToShowScheduleRemind, true)
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
        func resumeUserDataMigration() {
            self.didMoveToUserDataMigration = true
        }
        
        var didMoveToChangeDefaultRemindtime = false
        func changeDefaultRemindTime() {
            self.didMoveToChangeDefaultRemindtime = true
        }
        
        var didMoveToShowScheduleRemind = false
        func showScheduleReminds() {
            self.didMoveToShowScheduleRemind = true
        }
    }
}
