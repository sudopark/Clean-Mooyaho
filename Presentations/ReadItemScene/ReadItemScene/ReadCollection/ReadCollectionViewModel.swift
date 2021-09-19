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

import Domain
import CommonPresenting


// MARK: - ReadCollectionViewModel

public enum ReadCollectionItemSortOrder {
    case byCreatedAt(_ isAscending: Bool = false)
    case byLastUpdatedAt(_ isAscending: Bool = false)
    case byPriority(_ isAscending: Bool = false)
    case byCustomOrder
}

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
        let isLoading = PublishSubject<Bool>()
        let isShowReloadFail = PublishSubject<Bool>()
        let cellViewModels = BehaviorRelay<[ReadItemCellViewModel]?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func internalBinding() {
        self.bindDataSource()
    }
}


// MARK: - ReadCollectionViewModelImple Interactor

extension ReadCollectionViewModelImple {
    
    public func reloadCollectionItems() {
        
        let updateList: ([ReadItem]) -> Void = { [weak self] itemes in
            let cellViewModels = itemes.asCellViewModels()
            self?.subjects.cellViewModels.accept(cellViewModels)
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
        
    }
}


// MARK: - ReadCollectionViewModelImple Presenter

extension ReadCollectionViewModelImple {
    
    private func bindDataSource() {
        
    }
        
    public var cellViewModels: Observable<[ReadItemCellViewModel]> {
        return self.subjects.cellViewModels
            .compactMap { $0 }
    }
}

private extension Array where Element == ReadItem {
    
    func asCellViewModels() -> [ReadItemCellViewModel] {
        let transform: (ReadItem) -> ReadItemCellViewModel? = { item in
            switch item {
            case let collection as ReadCollection:
                return ReadCollectionCellViewModel(collection: collection)
                
            case let link as ReadLink:
                return ReadLinkCellViewModel(link: link)
                
            default: return nil
            }
        }
        return self.compactMap(transform)
    }
}
