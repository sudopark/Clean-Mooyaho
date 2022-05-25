//
//  ApplicationUsecase.swift
//  MooyahoApp
//
//  Created by sudo.park on 2021/05/25.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public protocol ApplicationUsecase {
    
    func updateApplicationActiveStatus(_ newStatus: ApplicationStatus)
    
    func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)>
    
    func userFCMTokenUpdated(_ newToken: String?)
    
    var currentSignedInMemeber: Observable<Member?> { get }
    
    var signedOut: Observable<Auth> { get }
}

// MARK: - ApplicationUsecaseImple

public final class ApplicationUsecaseImple: ApplicationUsecase {
    
    private let authUsecase: AuthUsecase
    private let memberUsecase: MemberUsecase
    private let readItemUsecase: ReadItemUsecase
    private let readItemCategoryUsecase: ReadItemCategoryUsecase
    private let shareUsecase: ShareReadCollectionUsecase
    private let crashLogger: CrashLogger
    
    public init(authUsecase: AuthUsecase,
                memberUsecase: MemberUsecase,
                readItemUsecase: ReadItemUsecase,
                readItemCategoryUsecase: ReadItemCategoryUsecase,
                shareUsecase: ShareReadCollectionUsecase,
                crashLogger: CrashLogger) {
        self.authUsecase = authUsecase
        self.memberUsecase = memberUsecase
        self.readItemUsecase = readItemUsecase
        self.readItemCategoryUsecase = readItemCategoryUsecase
        self.shareUsecase = shareUsecase
        self.crashLogger = crashLogger
        
        self.bindApplicationStatus()
        self.bindPushTokenUpload()
        
        self.bindLogging()
    }
    
    fileprivate struct Subjects {
        let applicationStatus = BehaviorRelay<ApplicationStatus>(value: .idle)
        let fcmToken = BehaviorSubject<String?>(value: nil)
    }
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - input

extension ApplicationUsecaseImple {
    
    public func updateApplicationActiveStatus(_ newStatus: ApplicationStatus) {
        self.subjects.applicationStatus.accept(newStatus)
    }
    
    private func bindApplicationStatus() {
        
        let status = self.subjects.applicationStatus.distinctUntilChanged()
        
        let didLanched = status.filter{ $0 == .launched }.take(1).map{ _ in }
        let enterForeground = status.filter{ $0 == .forground }.map{ _ in true }
        let enterBackground = status.filter{ $0 == .background }.map{ _ in false }
        let terminated = status.filter{ $0 == .terminate }.map{ _ in false }

        let isUserInUseApp = Observable
            .merge(didLanched.map{ true }, enterForeground, enterBackground, terminated)
            .distinctUntilChanged()
        
        let memberChanges = self.memberUsecase
            .currentMember.map { $0?.uid }.distinctUntilChanged().share()
        Observable.combineLatest(memberChanges, isUserInUseApp)
            .subscribe(onNext: { [weak self] memberID, isUse in
                guard let memberID = memberID, isUse == true else { return }
                self?.refreshSignInMemberBaseDatas(for: memberID)
            })
            .disposed(by: self.disposeBag)
        memberChanges
            .subscribe(onNext: { [weak self] _ in
                self?.refreshBaseSharedDatas()
            })
            .disposed(by: self.disposeBag)
    }

    private func refreshBaseSharedDatas() {
        self.readItemUsecase.refreshSharedFavoriteIDs()
    }
    
    private func refreshSignInMemberBaseDatas(for memberID: String) {
        self.memberUsecase.refreshMembers([memberID])
        self.shareUsecase.refreshMySharingColletionIDs()
        // TODO: 검색 가능한 단어 전부다 추출
    }
}

// MARK: - input: handle notification

extension ApplicationUsecaseImple {
    
    public func userFCMTokenUpdated(_ newToken: String?) {
        self.subjects.fcmToken.onNext(newToken)
    }
    
    private func bindPushTokenUpload() {
        
        let deviceID = AppEnvironment.deviceID
        let uploadToken: (String, String) -> Void = { [weak self] memberID, token in
            self?.memberUsecase.updatePushToken(memberID, deviceID: deviceID, newToken: token)
        }
        
        let currentMemberID = self.memberUsecase.currentMember.compactMap{ $0?.uid }.distinctUntilChanged()
        let fcmToken = self.subjects.fcmToken.compactMap{ $0 }.distinctUntilChanged()
        
        Observable.combineLatest(currentMemberID, fcmToken)
            .subscribe(onNext: uploadToken)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - output

extension ApplicationUsecaseImple {
    
    public func loadLastSignInAccountInfo() -> Maybe<(auth: Auth, member: Member?)> {
        
        typealias Pair = (auth: Auth, member: Member?)
        
        let appendWelcomeItemIfNeed: (Pair) -> Maybe<Pair>
        appendWelcomeItemIfNeed = { [weak self] pair in
            guard let self = self else { return .empty() }
            return self.appendWelcomeItemIfNeed(isSignIn: pair.member?.uid != nil)
                .catchAndReturn(())
                .map { pair }
        }
        
        return self.authUsecase.loadLastSignInAccountInfo()
            .flatMap(appendWelcomeItemIfNeed)
    }
    
    public var currentSignedInMemeber: Observable<Member?> {
        return self.memberUsecase.currentMember
    }
    
    public var signedOut: Observable<Auth> {
        return self.authUsecase.usersignInStatus
            .compactMap { event in
                guard case let .signOut(auth) = event else { return nil }
                return auth
            }
    }
    
    private func appendWelcomeItemIfNeed(isSignIn: Bool) -> Maybe<Void> {
        guard AppEnvironment.featureFlag.isEnable(.welcomeItem),
              isSignIn == false,
              self.readItemUsecase.didWelComeItemAdded() == false
        else {
            return .just()
        }
        
        let loadMyItems = self.readItemUsecase.loadMyItems().take(1).asMaybe()

        let saveWelcomeItemIfNeedWithMarking: ([ReadItem]) async throws -> Void?
        saveWelcomeItemIfNeedWithMarking = { [weak self] items in
            guard let self = self else { return nil }
            guard items.isEmpty else {
                return ()
            }
            
            let categories = ItemCategory.welcomeItemCategories
            _ = try await self.readItemCategoryUsecase.updateCategories(categories).value
            
            let welcomeItem = self.makeWelcomeLinkItem(with: categories)
            _ = try await self.readItemUsecase.saveLink(welcomeItem, at: nil).value
            return self.readItemUsecase.updateDidWelcomeItemAdded()
        }
        return loadMyItems
            .flatMap(do: saveWelcomeItemIfNeedWithMarking)
    }
    
    private func makeWelcomeLinkItem(with categories: [ItemCategory]) -> ReadLink {
        return ReadLink.makeWelcomeItem(AppEnvironment.welcomeItemURLPath)
            |> \.categoryIDs .~ categories.map { $0.uid }
    }
}


// MARK: - bind logging

extension ApplicationUsecaseImple {
    
    func bindLogging() {
        
        self.authUsecase.currentAuth
            .compactMap { $0?.userID }
            .subscribe(onNext: { [weak self] userID in
                self?.crashLogger.setupUserIdentifier(userID)
            })
            .disposed(by: self.disposeBag)
        
        self.subjects.applicationStatus
            .subscribe(onNext: { [weak self] status in
                self?.crashLogger.setupValue(status.rawValue, key: "Application Status")
            })
            .disposed(by: self.disposeBag)
    }
}


private extension ItemCategory {
    
    static var welcomeItemCategories: [ItemCategory] {
        let labels = ["guide".localized, "how-to-use".localized, "start".localized]
        let colors = self.colorCodes
        return labels.map { .init(name: $0, colorCode: colors.randomElement() ?? "")}
    }
}
