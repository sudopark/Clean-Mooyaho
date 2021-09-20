//
//  ReadCollectionViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - ReadCollectionViewModel

public protocol ReadCollectionViewModel: AnyObject {

    // interactor
    func reloadCollectionItems()
    func toggleShrinkListStyle()
//    func requestChangeOrder()
//    func finishEditCustomOrder()
//    func openItem(_ itemID: String)
    
    
    // presenter
//    var currentSortOrder: Observable<ReadCollectionItemSortOrder> { get }
    var cellViewModels: Observable<[ReadItemCellViewModel]> { get }
//    var updateCustomOrderEditing: Observable<Bool> { get }
//    func collectionPreviewThumbnail(for collectionID: String) -> Observable<ImageSource?>
//    func linkPreviewThumbnail(for linkID: String) -> Observable<ImageSource?>
}


// MARK: - ReadCollectionViewModelImple

public final class ReadCollectionViewModelImple: ReadCollectionViewModel {
    
    private let collectionID: String?
    private let readItemUsecase: ReadItemUsecase
    private let router: ReadCollectionRouting
    
    public init(collectionID: String?,
                readItemUsecase: ReadItemUsecase,
                router: ReadCollectionRouting) {
        self.collectionID = collectionID
        self.readItemUsecase = readItemUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        let isShrinkModeIsOn = BehaviorRelay<Bool?>(value: nil)
        let items = BehaviorRelay<[ReadItem]?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        
        let setupLatestsShrinkModeFlag: (Bool) -> Void = { [weak self] isOn in
            self?.subjects.isShrinkModeIsOn.accept(isOn)
        }
        self.readItemUsecase
            .loadShrinkModeIsOnOption()
            .subscribe(onSuccess: setupLatestsShrinkModeFlag)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - ReadCollectionViewModelImple Interactor

extension ReadCollectionViewModelImple {
    
    public func reloadCollectionItems() {
        
        let updateList: ([ReadItem]) -> Void = { [weak self] itemes in
            self?.subjects.items.accept(itemes)
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        let loadItems = self.collectionID
            .map{ self.readItemUsecase.loadCollectionItems($0) } ?? self.readItemUsecase.loadMyItems()
        loadItems
            .subscribe(onNext: updateList, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func toggleShrinkListStyle() {
        guard let oldValue = self.subjects.isShrinkModeIsOn.value else { return }
        let newValue = oldValue.invert()
        self.subjects.isShrinkModeIsOn.accept(newValue)
    }
}


// MARK: - ReadCollectionViewModelImple Presenter

extension ReadCollectionViewModelImple {
    
    public var cellViewModels: Observable<[ReadItemCellViewModel]> {
        
        let asCellViewModels: ([ReadItem], Bool) ->  [ReadItemCellViewModel]
        asCellViewModels = { items, isShrink in
            return items.asCellViewModels(isShrink: isShrink)
        }
        
        return Observable.combineLatest(
            self.subjects.items.compactMap{ $0 },
            self.subjects.isShrinkModeIsOn.compactMap { $0 },
            resultSelector: asCellViewModels
        )
    }
}

private extension Array where Element == ReadItem {
    
    func asCellViewModels(isShrink: Bool) -> [ReadItemCellViewModel] {
        let transform: (ReadItem) -> ReadItemCellViewModel? = { item in
            switch item {
            case let collection as ReadCollection:
                return ReadCollectionCellViewModel(collection: collection)
                    |> \.isShrink .~ isShrink
                
            case let link as ReadLink:
                return ReadLinkCellViewModel(link: link)
                    |> \.isShrink .~ isShrink
                
            default: return nil
            }
        }
        return self.compactMap(transform)
    }
}
