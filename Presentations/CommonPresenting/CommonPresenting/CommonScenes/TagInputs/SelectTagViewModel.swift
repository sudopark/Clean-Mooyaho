//
//  SelectTagViewModel.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/06/12.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain

// MARK: - CellviewModel

public struct TagCellViewModel {

    fileprivate let tag: Tag
    public var isSelected: Bool = false
    
    init(tag: Tag) {
        self.tag = tag
    }
    
    public var keyword: String { self.tag.keyword }
    public var emoji: String? { self.tag.emoji }
    
    func updateIsSeelctedFlag(_ newValue: Bool) -> Self {
        var sender = self
        sender.isSelected = newValue
        return sender
    }
}

// MARK: - SelectTagViewModel

public protocol SelectTagViewModel: AnyObject {
    
    // interactor
    func toggleSelect(_ cellViewModel: TagCellViewModel)
    func confirmSelect()
    func closeScene()
    
    // presenter
    var cellViewModels: Observable<[TagCellViewModel]> { get }
    var selectedTags: Observable<[Tag]> { get }
}


// MARK: - SelectTagViewModelImple

public final class SelectTagViewModelImple: SelectTagViewModel {
    
    private let router: SelectTagRouting
    
    public init(startWith tags: [Tag],
                total: [Tag],
                router: SelectTagRouting) {
        self.router = router
        
        self.setupInitialList(selected: tags, total: total)
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let cellViewModels = BehaviorRelay<[TagCellViewModel]>(value: [])
        let selectionSet = BehaviorRelay<Set<String>>(value: [])
        let selectedTag = PublishSubject<[Tag]>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectTagViewModelImple Interactor

extension SelectTagViewModelImple {
    
    private func setupInitialList(selected: [Tag], total tags: [Tag]) {
        let cellViewModels = tags.map{ TagCellViewModel(tag: $0) }
        self.subjects.cellViewModels.accept(cellViewModels)
        
        let selectedSet = Set(selected.map{ $0.keyword })
        self.subjects.selectionSet.accept(selectedSet)
    }

    public func toggleSelect(_ cellViewModel: TagCellViewModel) {
        
        var selectedSet = self.subjects.selectionSet.value
        let alreadySelected = selectedSet.contains(cellViewModel.keyword)
        if alreadySelected {
            selectedSet.remove(cellViewModel.keyword)
        } else {
            selectedSet.insert(cellViewModel.keyword)
        }
        self.subjects.selectionSet.accept(selectedSet)
    }
    
    public func confirmSelect() {
        
        let cellViewModels = self.subjects.cellViewModels.value
        let selectedSet = self.subjects.selectionSet.value
        let selectedTags = cellViewModels.filter{ selectedSet.contains($0.keyword) }.map{ $0.tag }
        
        self.subjects.selectedTag.onNext(selectedTags)
    }
    
    public func closeScene() {
        self.router.closeScene(animated: true, completed: nil)
    }
}


// MARK: - SelectTagViewModelImple Presenter

extension SelectTagViewModelImple {
 
    public var cellViewModels: Observable<[TagCellViewModel]> {
        
        let applySelectedInfo: ([TagCellViewModel], Set<String>) -> [TagCellViewModel]
        applySelectedInfo = { cellViewModels, selectedSet in
            return cellViewModels.map{ $0.updateIsSeelctedFlag(selectedSet.contains($0.keyword)) }
        }
        
        return Observable
            .combineLatest(self.subjects.cellViewModels,
                           self.subjects.selectionSet.distinctUntilChanged(),
                           resultSelector: applySelectedInfo)
    }
    
    public var selectedTags: Observable<[Tag]> {
        return self.subjects.selectedTag.asObservable()
    }
}
