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

import Domain
import CommonPresenting


// MARK: - MemberProfileViewModel

public protocol MemberCellViewModelTyoe {
    var compareID: Int { get }
}

public struct MemberInfoCellViewMdoel: MemberCellViewModelTyoe {
    
    let displayName: String
    let thumbnail: MemberThumbnail
    var intro: String?
    
    init(member: Member) {
        self.displayName = member.nickName ?? "Unnamed member"
        self.thumbnail = member.icon ?? .emoji("👻")
        self.intro = member.introduction
    }
    
    public var compareID: Int {
        var hasher = Hasher()
        hasher.combine(self.displayName)
        hasher.combine(self.thumbnail.hashValue)
        hasher.combine(self.intro)
        return hasher.finalize()
    }
}

public struct MemberCellSection: Equatable {
    let sectionName: String
    let cellViewModels: [MemberCellViewModelTyoe]
    
    public static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        return lhs.sectionName == rhs.sectionName
            && lhs.cellViewModels.map { $0.compareID } == rhs.cellViewModels.map { $0.compareID }
    }
}

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
        
        self.memberUsecase.loadMembers([self.memberID])
            .compactMap { $0.first }
            .subscribe(onSuccess: { [weak self] member in
                self?.subjects.member.accept(member)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func report() {
        
    }
}


// MARK: - MemberProfileViewModelImple Presenter

extension MemberProfileViewModelImple {
    
    public var sections: Observable<[MemberCellSection]> {
        
        let asSection: (Member) -> [MemberCellSection]
        asSection = { member in
            let memberCell = MemberInfoCellViewMdoel(member: member)
            return [
                MemberCellSection(sectionName: "info", cellViewModels: [memberCell])
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
