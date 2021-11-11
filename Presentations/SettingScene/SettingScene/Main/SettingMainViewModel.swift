//
//  SettingMainViewModel.swift
//  SettingScene
//
//  Created sudo.park on 2021/11/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public struct SettingItemCellViewModel: Equatable {
    
    enum Accessory: Equatable {
        case disclosure
        case accentValue(_ value: String)
    }
    
    let itemID: String
    let title: String
    var isEnable: Bool = true
    var accessory: Accessory = .disclosure
}

public struct SettingItemSection: Equatable {
    let sectionID: String
    let title: String
    let cellViewModels: [SettingItemCellViewModel]
}


// MARK: - SettingMainViewModel

public protocol SettingMainViewModel: AnyObject {

    // interactor
    func refresh()
    func selectItem(_ itemID: String)
    
    // presenter
    var sections: Observable<[SettingItemSection]> { get }
}


// MARK: - SettingMainViewModelImple

public final class SettingMainViewModelImple: SettingMainViewModel {
    
    private let memberUsecase: MemberUsecase
    private let remindOptionUsecase: RemindOptionUsecase
    private let router: SettingMainRouting
    private weak var listener: SettingMainSceneListenable?
    
    public init(memberUsecase: MemberUsecase,
                remindOptionUsecase: RemindOptionUsecase,
                router: SettingMainRouting,
                listener: SettingMainSceneListenable?) {
        
        self.memberUsecase = memberUsecase
        self.remindOptionUsecase = remindOptionUsecase
        self.router = router
        self.listener = listener
        
        self.bindCurrentMember()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    enum Section: String {
        case account
        case items
        case remind
    }
    
    enum Item {
        case editProfile
        case manageAccount
        case signIn
        case editCategories
//        case editSortOptions
        case userDataMigration
        case defaultRemidTime(RemindTime)
        case scheduledReminders
    }
    
    fileprivate final class Subjects {
        
        let defaultRemindTime = BehaviorRelay<RemindTime>(value: RemindTime.default)
        let currentMember = BehaviorRelay<Member?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindCurrentMember() {
        
        self.memberUsecase.currentMember
            .subscribe(onNext: { [weak self] member in
                self?.subjects.currentMember.accept(member)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SettingMainViewModelImple Interactor

extension SettingMainViewModelImple {
 
    public func refresh() {
        
        self.reloadRemindTime()
    }
    
    private func reloadRemindTime() {
        
        let updateTime: (RemindTime) -> Void = { time in
            self.subjects.defaultRemindTime.accept(time)
        }
        self.remindOptionUsecase
            .loadDefaultRemindTime()
            .subscribe(onSuccess: updateTime)
            .disposed(by: self.disposeBag)
    }
    
    public func selectItem(_ itemID: String) {
        switch itemID {
        case Item.editProfile.identifier:
            self.router.editProfile()
            
        case Item.manageAccount.identifier:
            self.router.manageAccount()
            
        case Item.signIn.identifier:
            self.router.requestSignIn()
            
        case Item.editCategories.identifier:
            self.router.editItemsCategory()
            
        case Item.userDataMigration.identifier:
            guard let member = self.subjects.currentMember.value else { return }
            self.router.resumeUserDataMigration(for: member.uid)
            
        case Item.defaultRemidTime(RemindTime.default).identifier:
            self.router.changeDefaultRemindTime()
            
        case Item.scheduledReminders.identifier:
            self.router.showScheduleReminds()
            
        default: break
        }
    }
}


// MARK: - SettingMainViewModelImple Presenter

extension SettingMainViewModelImple {
    
    public var sections: Observable<[SettingItemSection]> {
        
        let asSections: (Member?, RemindTime) -> [SettingItemSection]?
        asSections = { [weak self] member, remindTime in
            guard let self = self else { return nil }
            let accountSection = self.accountSection(for: member)
            let itemSection = self.itemSection(for: member)
            let remindSection = self.remindSection(remindTime)
            return [
                accountSection, itemSection, remindSection
            ]
        }
        
        return Observable
            .combineLatest(self.memberUsecase.currentMember, self.subjects.defaultRemindTime,
                           resultSelector: asSections)
            .compactMap { $0 }
            .distinctUntilChanged()
    }
    
    private func accountSection(for currentMember: Member?) -> SettingItemSection {
        let items: [Item] = currentMember != nil ? [.editProfile, .manageAccount] : [.signIn]
        let cells = items.map { $0.asCellViewModel() }
        return SettingItemSection(section: .account, with: cells)
    }
    
    private func itemSection(for currentMember: Member?) -> SettingItemSection {
        let cells: [SettingItemCellViewModel] = [
            Item.editCategories.asCellViewModel(),
            Item.userDataMigration.asCellViewModel(isEnable: currentMember != nil)
        ]
        return SettingItemSection(section: .items, with: cells)
    }
    
    private func remindSection(_ remindTime: RemindTime) -> SettingItemSection {
        let cells: [SettingItemCellViewModel] = [
            Item.defaultRemidTime(remindTime).asCellViewModel(),
            Item.scheduledReminders.asCellViewModel()
        ]
        return SettingItemSection(section: .remind, with: cells)
    }
}


private extension SettingItemSection {
    
    init(section: SettingMainViewModelImple.Section,
         with cellViewModels: [SettingItemCellViewModel]) {
        self.init(sectionID: section.rawValue, title: section.title,
                  cellViewModels: cellViewModels)
    }
}

extension SettingMainViewModelImple.Item {
    
    var identifier: String {
        switch self {
        case .editProfile: return "editProfile"
        case .manageAccount: return "manageAccount"
        case .signIn: return "signIn"
        case .editCategories: return "editCategories"
        case .userDataMigration: return "userDataMigration"
        case .defaultRemidTime: return "defaultRemidTime"
        case .scheduledReminders: return "scheduledReminders"
        }
    }
    
    private var title: String {
        switch self {
        case .editProfile: return "Edit profile".localized
        case .manageAccount: return "Manage Account".localized
        case .signIn: return "Signin".localized
        case .editCategories: return "Manage item category".localized
        case .userDataMigration: return "Manage temporary user data migration".localized
        case .defaultRemidTime: return "Default remind time".localized
        case .scheduledReminders: return "Scheduled reminds".localized
        }
    }
    
    private var accessory: SettingItemCellViewModel.Accessory {
        switch self {
        case let .defaultRemidTime(time): return .accentValue(time.asText)
        default: return .disclosure
        }
    }
    
    func asCellViewModel(isEnable: Bool = true) -> SettingItemCellViewModel {
        return SettingItemCellViewModel(itemID: self.identifier, title: self.title)
            |> \.accessory .~ self.accessory
            |> \.isEnable .~ isEnable
    }
}

extension SettingMainViewModelImple.Section {
    
    var title: String {
        switch self {
        case .account: return "Account"
        case .items: return "Items"
        case .remind: return "Remind"
        }
    }
}

private extension RemindTime {
    
    var asText: String {
        let date = self.asDate() ?? Date()
        return date.asText()
    }
    
    private func asDate() -> Date? {
        return Calendar.current.date(bySettingHour: self.hour, minute: self.minute, second: 0, of: Date())
    }
}

private extension Date {
    
    func asText() -> String {
        let form = DateFormatter()
        form.dateFormat = "a hh:mm"
        return form.string(from: self)
    }
}
