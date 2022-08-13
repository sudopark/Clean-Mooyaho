//
//  FavoriteItemsViewModel.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/12/01.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


// MARK: - FavoriteItemsViewModel

public protocol FavoriteItemsViewModel: AnyObject, Sendable {

    // interactor
    func refreshList()
    func loadMore()
    func selectCollection(_ uid: String)
    func selectLink(_ uid: String)
    
    // presenter
    var cellViewModels: Observable<[ReadItemCellViewModel]> { get }
    func readLinkPreview(for linkID: String) -> Observable<LinkPreview>
    var isRefreshing: Observable<Bool> { get }
}


// MARK: - FavoriteItemsViewModelImple

public final class FavoriteItemsViewModelImple: FavoriteItemsViewModel, @unchecked Sendable {
    
    private let pagingUsecase: FavoriteItemsPagingUsecase
    private let previewLoadUsecase: ReadLinkPreviewLoadUsecase
    private let categoryUsecase: ReadItemCategoryUsecase
    private let router: FavoriteItemsRouting
    private weak var listener: FavoriteItemsSceneListenable?
    
    public init(pagingUsecase: FavoriteItemsPagingUsecase,
                previewLoadUsecase: ReadLinkPreviewLoadUsecase,
                categoryUsecase: ReadItemCategoryUsecase,
                router: FavoriteItemsRouting,
                listener: FavoriteItemsSceneListenable?) {
        
        self.pagingUsecase = pagingUsecase
        self.previewLoadUsecase = previewLoadUsecase
        self.categoryUsecase = categoryUsecase
        self.router = router
        self.listener = listener
        
        self.bindCategories()
        self.bindItems()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects: Sendable {
        let items = BehaviorRelay<[ReadItem]?>(value: nil)
        let categoriesMap = BehaviorRelay<[String: ItemCategory]>(value: [:])
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
    
    private func bindCategories() {
     
        let idSources = self.subjects.items.compactMap { $0 }.map { $0.map { $0.uid } }
        self.categoryUsecase.requireCategoryMap(from: idSources)
            .subscribe(onNext: { [weak self] cateMap in
                self?.subjects.categoriesMap.accept(cateMap)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindItems() {
        
        self.pagingUsecase.items
            .subscribe(onNext: { [weak self] items in
                self?.subjects.items.accept(items)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - FavoriteItemsViewModelImple Interactor

extension FavoriteItemsViewModelImple {
    
    public func refreshList() {
        self.pagingUsecase.reloadFavoriteItems()
    }
    
    public func loadMore() {
        self.pagingUsecase.loadMoreItems()
    }
    
    public func selectCollection(_ uid: String) {
        
        self.listener?.favoriteItemsScene(didRequestJump: uid)
    }
    
    public func selectLink(_ uid: String) {
        guard let items = self.subjects.items.value,
              let link = items.first(where: { $0.uid == uid }) as? ReadLink
        else { return }
        self.router.showLinkDetail(link)
    }
    
    public func innerWebView(reqeustJumpTo collectionID: String?) {
        self.listener?.favoriteItemsScene(didRequestJump: collectionID)
    }
}


// MARK: - FavoriteItemsViewModelImple Presenter

extension FavoriteItemsViewModelImple {
    
    public var isRefreshing: Observable<Bool> {
        
        return self.pagingUsecase
            .isRefreshing
    }
    
    public func readLinkPreview(for linkID: String) -> Observable<LinkPreview> {
        guard let item = self.subjects.items.value?.first(where:  { $0.uid == linkID }) as? ReadLink
        else {
            return .empty()
        }
        return self.previewLoadUsecase.loadLinkPreview(item.link)
    }
    
    public var cellViewModels: Observable<[ReadItemCellViewModel]> {
        
        let asCellViewModels: ([ReadItem], [String: ItemCategory]) -> [ReadItemCellViewModel]
        asCellViewModels = { items, categoryMap in
            let transform: (ReadItem) -> ReadItemCellViewModel? = { item in
                switch item {
                case let collection as ReadCollection:
                    return ReadCollectionCellViewModel(item: collection)
                        |> \.categories .~ collection.categoryIDs.compactMap { categoryMap[$0] }
                case let link as ReadLink:
                    return ReadLinkCellViewModel(item: link)
                        |> \.categories .~ link.categoryIDs.compactMap { categoryMap[$0] }
                default: return nil
                }
            }
            
            return items.compactMap(transform)
        }
        
        return Observable.combineLatest(
            self.subjects.items.compactMap { $0 },
            self.subjects.categoriesMap,
            resultSelector: asCellViewModels
        )
        .distinctUntilChanged { $0.map { $0.presetingID } == $1.map { $0.presetingID } }
    }
}
