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

    private let tag: Domain.Tag
    public var isSelected: Bool = false
    
    init(tag: Domain.Tag) {
        self.tag = tag
    }
    
    public var keyword: String { self.tag.keyword }
    public var emoji: String? { self.tag.emoji }
}

// MARK: - SelectTagViewModel

public protocol SelectTagViewModel: AnyObject {
    
    // interactor
    func showUp()
    func toggleSelect(_ cellViewModel: TagCellViewModel)
    func confirmSelect()
    
    // presenter
    var cellViewModels: Observable<TagCellViewModel> { get }
    var selectedTags: Observable<[Domain.Tag]> { get }
}


// MARK: - SelectTagViewModelImple

public final class SelectTagViewModelImple: SelectTagViewModel {
    
    private let router: SelectTagRouting
    
    public init(router: SelectTagRouting) {
        self.router = router
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let cellViewModels = BehaviorRelay<[TagCellViewModel]>(value: [])
        let selectionSet = BehaviorRelay<[String]>(value: [])
        let selectedTag = PublishSubject<Domain.Tag>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectTagViewModelImple Interactor

extension SelectTagViewModelImple {
    
    public func showUp() {
        
    }
    
    public func toggleSelect(_ cellViewModel: TagCellViewModel) {
        
    }
    
    public func confirmSelect() {
        
    }
}


// MARK: - SelectTagViewModelImple Presenter

extension SelectTagViewModelImple {
 
    public var cellViewModels: Observable<TagCellViewModel> {
        return .empty()
    }
    
    public var selectedTags: Observable<[Domain.Tag]> {
        return .empty()
    }
}
