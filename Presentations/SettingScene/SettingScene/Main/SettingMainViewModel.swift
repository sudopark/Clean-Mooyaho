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
    func selectItem(_ typeName: String)
    
    // presenter
    var sections: Observable<[SettingItemSection]> { get }
}


// MARK: - SettingMainViewModelImple

public final class SettingMainViewModelImple: SettingMainViewModel {
    
    private let appID: String
    private let memberUsecase: MemberUsecase
    private let deviceInfoService: DeviceInfoService
    private let router: SettingMainRouting
    private weak var listener: SettingMainSceneListenable?
    
    public init(appID: String,
                memberUsecase: MemberUsecase,
                deviceInfoService: DeviceInfoService,
                router: SettingMainRouting,
                listener: SettingMainSceneListenable?) {
        
        self.appID = appID
        self.memberUsecase = memberUsecase
        self.deviceInfoService = deviceInfoService
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
        case service
    }
    
    enum Item {
        case editProfile
        case manageAccount
        case signIn
        case editCategories
        case userDataMigration
        case appVersion(String)
        case feedback
        case sourceCode
    }
    
    fileprivate final class Subjects {
        
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
 
    public func refresh() { }
    
    public func selectItem(_ typeName: String) {
        switch typeName {
        case Item.editProfile.typeName:
            self.router.editProfile()
            
        case Item.manageAccount.typeName:
            self.router.manageAccount()
            
        case Item.signIn.typeName:
            self.router.requestSignIn()
            
        case Item.editCategories.typeName:
            self.router.editItemsCategory()
            
        case Item.userDataMigration.typeName:
            guard let member = self.subjects.currentMember.value else { return }
            self.router.resumeUserDataMigration(for: member.uid)
            
        case Item.appVersion("").typeName:
            let urlPath = "http://itunes.apple.com/app/id\(appID)"
            self.router.openURL(urlPath)
            
        case Item.feedback.typeName:
            self.router.routeToEnterFeedback()
            
        case Item.sourceCode.typeName:
            let path = "https://github.com/sudopark/Clean-Mooyaho"
            self.router.openURL(path)
            
        default: break
        }
    }
}


// MARK: - SettingMainViewModelImple Presenter

extension SettingMainViewModelImple {
    
    public var sections: Observable<[SettingItemSection]> {
        
        let asSections: (Member?) -> [SettingItemSection]?
        asSections = { [weak self] member in
            guard let self = self else { return nil }
            let accountSection = self.accountSection(for: member)
            let itemSection = self.itemSection(for: member)
            let serviceSection = self.serviceSection()
            return [
                accountSection, itemSection, serviceSection
            ]
        }
        
        return self.memberUsecase.currentMember
            .startWith(nil)
            .map(asSections)
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
    
    private func serviceSection() -> SettingItemSection {
        let appVersion = self.deviceInfoService.appVersion()
        let cells: [SettingItemCellViewModel] = [
            Item.appVersion(appVersion).asCellViewModel(),
            Item.feedback.asCellViewModel(),
            Item.sourceCode.asCellViewModel()
        ]
        return SettingItemSection(section: .service, with: cells)
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
    
    var typeName: String {
        switch self {
        case .editProfile: return "editProfile"
        case .manageAccount: return "manageAccount"
        case .signIn: return "signIn"
        case .editCategories: return "editCategories"
        case .userDataMigration: return "userDataMigration"
        case .appVersion: return "appVersion"
        case .feedback: return "feedback"
        case .sourceCode: return "sourceCode"
        }
    }
    
    private var title: String {
        switch self {
        case .editProfile: return "Edit profile".localized
        case .manageAccount: return "Manage Account".localized
        case .signIn: return "Signin".localized
        case .editCategories: return "Manage item category".localized
        case .userDataMigration: return "Manage temporary user data migration".localized
        case .appVersion: return "App version".localized
        case .feedback: return "Feedback".localized
        case .sourceCode: return "Source code".localized
        }
    }
    
    private var accessory: SettingItemCellViewModel.Accessory {
        switch self {
        case let .appVersion(version): return .accentValue(version)
        default: return .disclosure
        }
    }
    
    func asCellViewModel(isEnable: Bool = true) -> SettingItemCellViewModel {
        return SettingItemCellViewModel(itemID: self.typeName, title: self.title)
            |> \.accessory .~ self.accessory
            |> \.isEnable .~ isEnable
    }
}

extension SettingMainViewModelImple.Section {
    
    var title: String {
        switch self {
        case .account: return "Account"
        case .items: return "Items"
        case .service: return "Service"
        }
    }
}
