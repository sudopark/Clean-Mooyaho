//
//  MainViewModel.swift
//  MooyahoApp
//
//  Created sudo.park on 2021/05/20.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import MemberScenes
import CommonPresenting

// MARK: - MainViewModel

public enum ActivationStatus: Equatable {
    case unavail
    case activable
    case activated
}

public protocol MainViewModel: AnyObject {

    // interactor
    func setupSubScenes()
    func requestOpenSlideMenu()
    func requestAddNewItem()
    func checkHasSomeSuggestAddItem()
    func requestAddNewItemUsingURLInClipBoard()
    func toggleIsReadItemShrinkMode()
    func toggleShareStatus()
    func toggleSharedCollectionFavorite()
    func showSharedCollectionDetail()
    func returnToMyReadCollections()
    
    // presenter
    var currentMemberProfileImage: Observable<Thumbnail> { get }
    var isReadItemShrinkModeOn: Observable<Bool> { get }
    var showAddItemInUsingURLInClipBoard: Observable<String> { get }
    var currentCollectionRoot: Observable<CollectionRoot> { get }
    var shareStatus: Observable<ActivationStatus> { get }
    var favoriteSharedCollectionStatus: Observable<ActivationStatus> { get }
    var currentSharedCollectionOwnerInfo: Observable<Member?> { get }
}


// MARK: - MainViewModelImple

public final class MainViewModelImple: MainViewModel {
    
    enum CurrentSubCollectionID: Equatable {
        case mine(String?)
        case shared(String)
    }
    
    private let memberUsecase: MemberUsecase
    private let readItemOptionUsecase: ReadItemOptionsUsecase
    private let addItemSuggestUsecase: ReadLinkAddSuggestUsecase
    private let shareCollectionUseCase: ShareReadCollectionUsecase
    private let router: MainRouting
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private weak var readCollectionMainSceneInteractor: ReadCollectionMainSceneInteractable?
    
    public init(memberUsecase: MemberUsecase,
                readItemOptionUsecase: ReadItemOptionsUsecase,
                addItemSuggestUsecase: ReadLinkAddSuggestUsecase,
                shareCollectionUsecase: ShareReadCollectionUsecase,
                router: MainRouting) {
        
        self.memberUsecase = memberUsecase
        self.readItemOptionUsecase = readItemOptionUsecase
        self.addItemSuggestUsecase = addItemSuggestUsecase
        self.shareCollectionUseCase = shareCollectionUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    fileprivate final class Subjects {
        let isReadItemShrinkModeOn = BehaviorRelay<Bool?>(value: nil)
        let suggestAddItemURL = BehaviorRelay<String?>(value: nil)
        let currentMember = BehaviorRelay<Member?>(value: nil)
        let currentCollectionRoot = BehaviorRelay<CollectionRoot>(value: .myCollections)
        let currentSubCollectionID = BehaviorRelay<CurrentSubCollectionID?>(value: nil)
        let sharingIDSets = BehaviorRelay<Set<String>>(value: [])
        let isToggling = BehaviorRelay<Bool>(value: false)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    private func internalBinding() {
        
        self.memberUsecase.currentMember
            .subscribe(onNext: { [weak self] member in
                self?.subjects.currentMember.accept(member)
            })
            .disposed(by: self.disposeBag)
        
        self.readItemOptionUsecase
            .isShrinkModeOn
            .subscribe(onNext: { [weak self] isOn in
                self?.subjects.isReadItemShrinkModeOn.accept(isOn)
            })
            .disposed(by: self.disposeBag)
        
        self.shareCollectionUseCase
            .mySharingCollectionIDs
            .map { Set($0) }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] ids in
                self?.subjects.sharingIDSets.accept(ids)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - MainViewModelImple Interactor

extension MainViewModelImple {
    
    public func setupSubScenes() {
        self.readCollectionMainSceneInteractor = self.router.addReadCollectionScene()
    }
    
    public func requestOpenSlideMenu() {
        
        self.router.openSlideMenu()
    }
    
    public func requestAddNewItem() {
        
        self.router.askAddNewitemType { [weak self] isCollectionSelected in
            guard let interactor = self?.readCollectionMainSceneInteractor else { return }
            return isCollectionSelected
                ? interactor.addNewCollectionItem()
                : interactor.addNewReadLinkItem()
        }
    }
    
    public func checkHasSomeSuggestAddItem() {
        
        let suggestIfNeed: (String?) -> Void = { [weak self] url in
            guard let self = self, let url = url else { return }
            self.subjects.suggestAddItemURL.accept(url)
        }
        
        self.addItemSuggestUsecase
            .loadSuggestAddNewItemByURLExists()
            .subscribe(onSuccess: suggestIfNeed)
            .disposed(by: self.disposeBag)
    }
    
    public func requestAddNewItemUsingURLInClipBoard() {
        
        guard let url = self.subjects.suggestAddItemURL.value,
              let interactor = self.readCollectionMainSceneInteractor else { return }
        interactor.addNewReaedLinkItem(with: url)
    }
    
    public func toggleIsReadItemShrinkMode() {
        guard let newValue = self.subjects.isReadItemShrinkModeOn.value?.invert() else { return }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        self.readItemOptionUsecase
            .updateLatestIsShrinkModeIsOn(newValue)
            .subscribe(onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func toggleShareStatus() {
        guard case let .mine(collectionID) = self.subjects.currentSubCollectionID.value,
              let subCollectionID = collectionID,
              self.subjects.isToggling.value == false else { return }
        let shareIDSet = self.subjects.sharingIDSets.value
        let isSharing = shareIDSet.contains(subCollectionID)
        return isSharing
            ? self.router.showSharingCollectionInfo(subCollectionID)
            : self.startShare(subCollectionID)
    }
    
    private func startShare(_ subCollectionID: String) {
        
        let sharePrepared: (SharedReadCollection) -> Void = { [weak self] collection in
            self?.subjects.isToggling.accept(false)
            let url = "\(AppEnvironment.shareScheme)://\(collection.fullSharePath)"
            self?.router.presentShareSheet(with: url)
        }
        
        self.subjects.isToggling.accept(true)
        self.shareCollectionUseCase.shareCollection(subCollectionID)
            .subscribe(onSuccess: sharePrepared, onError: self.handleError())
            .disposed(by: self.disposeBag)
    }
    
    private func handleError() -> (Error) -> Void {
        return { [weak self] error in
            self?.subjects.isToggling.accept(false)
            self?.router.alertError(error)
        }
    }
    
    public func toggleSharedCollectionFavorite() {
        // TODO
    }
    
    public func showSharedCollectionDetail() {
        // TODO
    }
    
    public func returnToMyReadCollections() {
        // TODO
    }
}

// MRAK: - MainViewModel + Interactable

extension MainViewModelImple: MainSceneInteractable {
    
    public func mainSlideMenuDidRequestSignIn() {
        self.router.presentSignInScene()
    }
    
    public func signIn(didCompleted member: Member) {
        self.readCollectionMainSceneInteractor = self.router.replaceReadCollectionScene()
        self.router.presentUserDataMigrationScene(member.uid)
    }
    
    public func showSharedReadCollection(_ collection: SharedReadCollection) {
        logger.print(level: .goal, "switch curent collection aclled from shared collection => \(collection.name)")
        self.router.showSharedCollection(collection)
    }
    
    public func readCollection(didChange root: CollectionRoot) {
        logger.print(level: .debug, "didChange to read collection root => \(root)")
        self.subjects.currentCollectionRoot.accept(root)
    }
    
    public func readCollection(didShowMy subCollectionID: String?) {
        logger.print(level: .debug, "did show shared subCollection: \(subCollectionID ?? "nil")")
        self.subjects.currentSubCollectionID.accept(.mine(subCollectionID))
    }
    
    public func readCollection(didShowShared subCollectionID: String) {
        logger.print(level: .debug, "did show my sub collection: \(subCollectionID)")
        self.subjects.currentSubCollectionID.accept(.shared(subCollectionID))
    }
}


// MARK: - MainViewModelImple Presenter

extension MainViewModelImple {
 
    public var currentMemberProfileImage: Observable<Thumbnail> {
        return self.subjects.currentMember
            .compactMap{ $0?.icon }
            .startWith(Member.memberDefaultEmoji)
    }
    
    public var isReadItemShrinkModeOn: Observable<Bool> {
        return self.subjects
            .isReadItemShrinkModeOn
            .compactMap { $0 }
            .distinctUntilChanged()
    }
    
    public var showAddItemInUsingURLInClipBoard: Observable<String> {
        return self.subjects
            .suggestAddItemURL
            .compactMap { $0 }
    }
    
    public var currentCollectionRoot: Observable<CollectionRoot> {
        return self.subjects.currentCollectionRoot
            .asObservable()
    }
    
    public var shareStatus: Observable<ActivationStatus> {
        
        let selectStatus: (CurrentSubCollectionID, Set<String>) -> ActivationStatus
        selectStatus = { subCollection, sharedIDs in
            guard case let .mine(collectionID) = subCollection,
                  let subCollectionID = collectionID else { return .unavail }
            return sharedIDs.contains(subCollectionID) ? .activated : .activable
        }
        
        return Observable
            .combineLatest(self.subjects.currentSubCollectionID.compactMap { $0 },
                           self.subjects.sharingIDSets,
                           resultSelector: selectStatus)
            .distinctUntilChanged()
    }
    
    public var favoriteSharedCollectionStatus: Observable<ActivationStatus> {
        return .empty()
    }
    
    public var currentSharedCollectionOwnerInfo: Observable<Member?> {
        return .empty()
    }
}
