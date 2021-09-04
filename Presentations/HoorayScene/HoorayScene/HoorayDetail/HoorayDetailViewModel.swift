//
//  HoorayDetailViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/08/26.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - HoorayDetailCellViewModel

public protocol HoorayDetailCellViewModelType { }

public struct HoorayDetailHeaderCellViewModel: HoorayDetailCellViewModelType {
    
    public let userID: String
    public let placeID: String?
    public let publishedTimeAgoText: String
}

public struct HoorayDetailContentCellViewModel: HoorayDetailCellViewModelType {
    
    public let message: String
    public let tags: [String]
    public let image: ImageSource?
}

public struct HoorayDetailReactionsCellViewModel: HoorayDetailCellViewModelType { }


// MARK: - HoorayDetailViewModel

public protocol HoorayDetailViewModel: AnyObject {

    // interactor
    func loadDetail()
    
    // presenter
    var isLoadingFail: Observable<Void> { get }
    var cellViewModels: Observable<[HoorayDetailCellViewModelType]> { get }
    func memberInfo(for memberID: String) -> Observable<MemberInfo>
    func placeName(for placeID: String) -> Observable<String>
    var ackCount: Observable<Int> { get }
    var reactions: Observable<[ReactionGroup]> { get }
}


// MARK: - HoorayDetailViewModelImple

public final class HoorayDetailViewModelImple: HoorayDetailViewModel {
    
    private let hoorayID: String
    private let hoorayUsecase: HoorayUsecase
    private let memberUsecase: MemberUsecase
    private let placeUsecase: PlaceUsecase
    private let router: HoorayDetailRouting
    
    public init(hoorayID: String,
                hoorayUsecase: HoorayUsecase,
                memberUsecase: MemberUsecase,
                placeUsecase: PlaceUsecase,
                router: HoorayDetailRouting) {
        self.hoorayID = hoorayID
        self.hoorayUsecase = hoorayUsecase
        self.memberUsecase = memberUsecase
        self.placeUsecase = placeUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let currentMember = BehaviorSubject<Member?>(value: nil)
        let isLoadFail = PublishSubject<Void>()
        let hooray = BehaviorRelay<Hooray?>(value: nil)
        let ackSets = BehaviorRelay<Set<HoorayAckInfo>>(value: [])
        let reactions = BehaviorRelay<[String: Set<HoorayReaction>]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        
        self.memberUsecase.currentMember
            .subscribe(onNext: { [weak self] member in
                self?.subjects.currentMember.onNext(member)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - HoorayDetailViewModelImple Interactor

extension HoorayDetailViewModelImple {
    
    public func loadDetail() {
        
        let updateCells: (HoorayDetail) -> Void = { [weak self] detail in
            self?.subjects.hooray.accept(detail.hoorayInfo)
            self?.updateHoorayAckCount(detail.acks)
            self?.updateHoorayReactions(detail.reactions)
        }
        
        let alertLoadFail: (Error) -> Void = { [weak self] _ in
            self?.subjects.isLoadFail.onNext()
        }
        
        self.hoorayUsecase
            .loadHoorayHoorayDetail(self.hoorayID)
            .subscribe(onNext: updateCells, onError: alertLoadFail)
            .disposed(by: self.disposeBag)
    }
    
    private func updateHoorayAckCount(_ acks: [HoorayAckInfo]) {
        let newSet = self.subjects.ackSets.value.union(Set(acks))
        self.subjects.ackSets.accept(newSet)
        
    }
    
    private func updateHoorayReactions(_ reactions: [HoorayReaction]) {
        var newDict = self.subjects.reactions.value
        reactions.forEach {
            newDict[$0.groupKey] = (newDict[$0.groupKey] ?? []).union([$0])
        }
        self.subjects.reactions.accept(newDict)
    }
}


// MARK: - HoorayDetailViewModelImple Presenter

extension HoorayDetailViewModelImple {
    
    public var isLoadingFail: Observable<Void> {
        return self.subjects.isLoadFail.asObservable()
    }
    
    public var cellViewModels: Observable<[HoorayDetailCellViewModelType]> {
        return self.subjects.hooray
            .compactMap{ $0?.asCellViewModels() }
    }
    
    public func memberInfo(for memberID: String) -> Observable<MemberInfo> {
        return self.memberUsecase
            .members(for: [memberID])
            .compactMap{ $0[memberID] }
            .map{ MemberInfo(member: $0) }
            .distinctUntilChanged()
    }
    
    public func placeName(for placeID: String) -> Observable<String> {
        return self.placeUsecase
            .place(placeID)
            .map{ $0.title }
            .distinctUntilChanged()
    }
    
    public var ackCount: Observable<Int> {
        return self.subjects.ackSets
            .map{ $0.count }
            .distinctUntilChanged()
    }
    
    public var reactions: Observable<[ReactionGroup]> {
        let groupping: ([String: Set<HoorayReaction>], Member?) -> [ReactionGroup]
        groupping = { dict, me in
            return dict.values.compactMap { reactionSet in
                let isIncludeMine = reactionSet.contains(where: { $0.reactMemberID == me?.uid })
                return ReactionGroup(reactions: Array(reactionSet), isIncludeMine: isIncludeMine)
            }
        }
        return Observable
            .combineLatest(self.subjects.reactions, self.subjects.currentMember,
                           resultSelector: groupping)
    }
}

private extension Hooray {
    
    func asCellViewModels() -> [HoorayDetailCellViewModelType] {
        return [
            HoorayDetailHeaderCellViewModel(userID: self.publisherID,
                                            placeID: self.placeID,
                                            publishedTimeAgoText: self.timeStamp.timeAgoText),
            HoorayDetailContentCellViewModel(message: self.message,
                                             tags: self.tags,
                                             image: self.image),
            HoorayDetailReactionsCellViewModel()
        ]
    }
}
