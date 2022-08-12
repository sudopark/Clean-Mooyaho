//
//  MemberProfileViewModel.swift
//  MemberScenes
//
//  Created sudo.park on 2021/12/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - cellviewModels + section

public protocol MemberCellViewModelType {
    var compareID: Int { get }
}

public struct MemberInfoCellViewMdoel: MemberCellViewModelType {
    
    let displayName: String
    let thumbnail: MemberThumbnail
    
    init(member: Member) {
        self.displayName = member.nickName ?? "Unnamed member".localized
        self.thumbnail = member.icon ?? .emoji("👻")
    }
    
    public var compareID: Int {
        var hasher = Hasher()
        hasher.combine(self.displayName)
        hasher.combine(self.thumbnail.hashValue)
        return hasher.finalize()
    }
}

public struct MemberIntroCellViewModel: MemberCellViewModelType {
    
    let intro: String
    
    public var compareID: Int { self.intro.hashValue }
}

public struct MemberCellSection: Equatable {
    let sectionName: String
    let cellViewModels: [MemberCellViewModelType]
    
    public static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.sectionName == rhs.sectionName
            && lhs.cellViewModels.map { $0.compareID } == rhs.cellViewModels.map { $0.compareID }
    }
}

// MARK: - MemberProfileViewModel

@MainActor
public protocol MemberProfileViewModel: AnyObject {

    // interactor
    func refresh()
    func report()
    
    // presenter
    var sections: Observable<[MemberCellSection]> { get }
}


// MARK: - MemberProfileViewModelImple

public final class MemberProfileViewModelImple: MemberProfileViewModel {
    
    private let memberID: String
    private let memberUsecase: MemberUsecase
    private let router: MemberProfileRouting
    private weak var listener: MemberProfileSceneListenable?
    
    public init(memberID: String,
                memberUsecase: MemberUsecase,
                router: MemberProfileRouting,
                listener: MemberProfileSceneListenable?) {
        
        self.memberID = memberID
        self.memberUsecase = memberUsecase
        self.router = router
        self.listener = listener
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let member = BehaviorRelay<Member?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - MemberProfileViewModelImple Interactor

extension MemberProfileViewModelImple {
    
    public func refresh() {
        
        let handleRefreshedMemnber: (Member) -> Void = { [weak self] member in
            guard member.isDeactivated == false else {
                self?.alertMemberDeactivated()
                return
            }
            self?.subjects.member.accept(member)
        }
        self.memberUsecase.loadMembers([self.memberID])
            .compactMap { $0.first }
            .subscribe(onSuccess: handleRefreshedMemnber)
            .disposed(by: self.disposeBag)
    }
    
    private func alertMemberDeactivated() {
        
        let close: (() -> Void)? = { [weak self] in
            self?.router.closeScene(animated: true, completed: nil)
        }
        
        let form: AlertForm = .init()
            |> \.message .~ pure("This account cannot be viewed.".localized)
            |> \.customConfirmText .~ pure("Close".localized)
            |> \.confirmed .~ close
            |> \.isSingleConfirmButton .~ true
        
        self.router.alertForConfirm(form)
    }
    
    public func report() {
        
    }
}


// MARK: - MemberProfileViewModelImple Presenter

extension MemberProfileViewModelImple {
    
    public var sections: Observable<[MemberCellSection]> {
        
        let asSection: (Member) -> [MemberCellSection]
        asSection = { member in
            let infoCell = MemberInfoCellViewMdoel(member: member)
            let introCell = member.introduction.map { MemberIntroCellViewModel(intro: $0) }
            let infoSectionCells: [MemberCellViewModelType?] = [infoCell, introCell]
            return [
                MemberCellSection(sectionName: "Info".localized,
                                  cellViewModels: infoSectionCells.compactMap { $0 })
            ]
        }
        return self.subjects.member.compactMap { $0 }
            .map(asSection)
            .distinctUntilChanged()
            
    }
}

private extension Thumbnail {
    
    var hashValue: Int {
        switch self {
        case let .emoji(value): return value.hashValue
        case let .imageSource(source): return source.path.hashValue
        }
    }
}
