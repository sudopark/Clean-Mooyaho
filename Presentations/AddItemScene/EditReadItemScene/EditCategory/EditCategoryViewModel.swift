//
//  EditCategoryViewModel.swift
//  EditReadItemScene
//
//  Created sudo.park on 2021/10/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public protocol SuggestingCategoryCellViewModelType {
    
    var name: String { get }
    var colorCode: String { get }
    
    var customCompareKey: Int { get }
}

public struct SuggestingCategoryCellViewModel: SuggestingCategoryCellViewModelType {
    public let uid: String
    public let name: String
    public let colorCode: String
    
    public init(_ category: ItemCategory) {
        self.uid = category.uid
        self.name = category.name
        self.colorCode = category.colorCode
    }
    
    public var customCompareKey: Int {
        var hasher = Hasher()
        hasher.combine("suggest_cell")
        hasher.combine(self.uid)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}

public struct SuggestMakeNewCategoryCellViewMdoel: SuggestingCategoryCellViewModelType {
    public let name: String
    public let colorCode: String
    
    public init(_ name: String, _ colorCode: String) {
        self.name = name
        self.colorCode = colorCode
    }
    
    public var customCompareKey: Int {
        var hasher = Hasher()
        hasher.combine("new")
        hasher.combine(self.name)
        hasher.combine(self.colorCode)
        return hasher.finalize()
    }
}

// MARK: - EditCategoryViewModel

public protocol EditCategoryViewModel: AnyObject {

    // interactor
    func prepareCategoryList()
    func suggest(_ name: String)
    func loadMore()
    func select(_ uid: String)
    func deselect(_ uid: String)
    func makeNew(_ model: SuggestMakeNewCategoryCellViewMdoel)
    func changeColor()
    func confirmSelect()
    
    
    // presenter
    var cellViewModels: Observable<[SuggestingCategoryCellViewModelType]> { get }
    var selectedCellViewModels: Observable<[SuggestingCategoryCellViewModel]> { get }
    var confirmActionTitleBySelectedCount: Observable<String> { get }
    var isProcessing: Observable<Bool> { get }
    var clearText: Observable<Void> { get }
    var scrollToLastSelectionSection: Observable<Int> { get }
}


// MARK: - EditCategoryViewModelImple

public final class EditCategoryViewModelImple: EditCategoryViewModel {
    
    private let categoryUsecase: ReadItemCategoryUsecase
    private let suggestUsecase: SuggestCategoryUsecase
    private let router: EditCategoryRouting
    private weak var listener: EditCategorySceneListenable?
    
    public init(startWith selection: [ItemCategory],
                categoryUsecase: ReadItemCategoryUsecase,
                suggestUsecase: SuggestCategoryUsecase,
                router: EditCategoryRouting,
                listener: EditCategorySceneListenable?) {
        
        self.categoryUsecase = categoryUsecase
        self.suggestUsecase = suggestUsecase
        self.router = router
        self.listener = listener
        self.subjects = .init(startWith: selection)
        
        self.bindSuggestResult()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
        LeakDetector.instance.expectDeallocate(object: self.subjects)
    }
    
    fileprivate final class Subjects {
        
        let latestCategories = BehaviorRelay<[ItemCategory]>(value: [])
        let suggestedCategories = BehaviorRelay<SuggestCategoryCollection?>(value: nil)
        let randColorCode = BehaviorSubject<String>(value: ItemCategory.colorCodes.randomElement() ?? "")
        let selectedMap: BehaviorRelay<SelectedCellMap>
        let isMakingCategory = BehaviorRelay<Bool>(value: false)
        let clearText = PublishSubject<Void>()
        let scrollToLastSelectionSection = PublishSubject<Int>()
        
        init(startWith: [ItemCategory]) {
            var initialMap = SelectedCellMap()
            startWith.forEach {
                initialMap[$0.uid] = .init($0)
            }
            self.selectedMap = .init(value: initialMap)
        }
    }
    
    private let subjects: Subjects
    private let disposeBag = DisposeBag()
    
    private func bindSuggestResult() {
        
        self.suggestUsecase.suggestedCategories
            .subscribe(onNext: { [weak self] result in
                self?.subjects.suggestedCategories.accept(result)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - EditCategoryViewModelImple Interactor

extension EditCategoryViewModelImple {
    
    public func prepareCategoryList() {
        
        self.suggestUsecase.loadLatestCategories()
            .subscribe(onNext: { [weak self] latests in
                let categories = latests.map { $0.category }
                self?.subjects.latestCategories.accept(categories)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func suggest(_ name: String) {
        self.suggestUsecase.startSuggestCategories(query: name)
    }
    
    public func loadMore() {
        self.suggestUsecase.loadMore()
    }
    
    private var totalCategories: [ItemCategory] {
        return self.subjects.latestCategories.value
            + (self.subjects.suggestedCategories.value?.categories.map { $0.category } ?? [])
    }
    
    public func select(_ uid: String) {
        var selected = self.subjects.selectedMap.value
        guard selected.isExists(uid) == false,
              let category = self.totalCategories.first(where: { $0.uid == uid }) else {
            return
        }
        
        let cellViewModel = SuggestingCategoryCellViewModel(category)
        selected[uid] = cellViewModel
        self.subjects.selectedMap.accept(selected)
        
        let lastIndex = selected.count-1
        self.subjects.scrollToLastSelectionSection.onNext(lastIndex)
        
        self.resetSuggest()
    }
    
    public func deselect(_ uid: String) {
        var selected = self.subjects.selectedMap.value
        guard selected.isExists(uid) else { return }
        selected[uid] = nil
        self.subjects.selectedMap.accept(selected)
    }
    
    public func makeNew(_ model: SuggestMakeNewCategoryCellViewMdoel) {
        
        guard self.subjects.isMakingCategory.value == false else { return }
        
        let handleMade: (ItemCategory) -> Void = { [weak self] newCategory in
            self?.subjects.isMakingCategory.accept(false)
            self?.appendNewMadeCategory(newCategory)
            self?.resetSuggest()
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isMakingCategory.accept(false)
            self?.router.alertError(error)
        }
        
        self.categoryUsecase.makeCategory(model.name, colorCode: model.colorCode)
            .subscribe(onSuccess: handleMade, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func appendNewMadeCategory(_ category: ItemCategory) {
        let cellViewModel = SuggestingCategoryCellViewModel(category)
        var selectMap = self.subjects.selectedMap.value
        selectMap[category.uid] = cellViewModel
        self.subjects.selectedMap.accept(selectMap)
        
        self.appendNewcategoryAtDefaultList(category)
        
        let lastIndex = selectMap.count-1
        self.subjects.scrollToLastSelectionSection.onNext(lastIndex)
    }
    
    private func appendNewcategoryAtDefaultList(_ category: ItemCategory) {
        var defaults = self.subjects.latestCategories.value
        guard defaults.contains(where: { $0.uid == category.uid }) == false else { return }
        defaults.append(category)
        self.subjects.latestCategories.accept(defaults)
    }
    
    public func confirmSelect() {
        
        let selectedCategories = self.subjects.selectedMap.value.cellViewModels.map {
            ItemCategory(uid: $0.uid, name: $0.name, colorCode: $0.colorCode)
        }
        
        self.router.closeScene(animated: true) { [weak self] in
            self?.listener?.editCategory(didSelect: selectedCategories)
        }
    }
    
    private func resetSuggest() {
        self.subjects.clearText.onNext()
        self.suggestUsecase.stopSuggest()
        self.subjects.randColorCode.onNext(ItemCategory.colorCodes.randomElement() ?? "")
    }
}


// MARK: - EditCategoryViewModelImple Interactor + chaneg color

extension EditCategoryViewModelImple {
    
    public func changeColor() {
        let currentColor = try? self.subjects.randColorCode.value()
        let totalColors = ItemCategory.colorCodes
        self.router.showColorPicker(startWith: currentColor, sources: totalColors)
    }
    
    public func colorSelect(didSeelctColor hexCode: String) {
        self.subjects.randColorCode.onNext(hexCode)
    }
}


// MARK: - EditCategoryViewModelImple Presenter

extension EditCategoryViewModelImple {
    
    public var cellViewModels: Observable<[SuggestingCategoryCellViewModelType]> {
     
        typealias CVM = SuggestingCategoryCellViewModelType
        
        let switchSuggestResult: (SuggestCategoryCollection?) -> Observable<SuggestCategoryCollection>
        switchSuggestResult = { [weak self] result in
            guard let self = self else { return .empty() }
            guard (result?.query.isEmpty ?? true) == true else {
                return .just(result ?? .empty(result?.query ?? ""))
            }
            return self.subjects.latestCategories
                .map { SuggestCategoryCollection.defaultList($0, for: result?.query) }
        }
        
        let suggestedResult = self.subjects.suggestedCategories.flatMap(switchSuggestResult)
        
        let asCellViewModels: (SuggestCategoryCollection, SelectedCellMap, String) -> [CVM]
        asCellViewModels = { collection, selectMap, colorCode in
            let cvms = collection.categories.map { $0.category }.asCellViewModel(without: selectMap)
            guard collection.isNotFoundQueryMatchingItem() else { return cvms }
            return [SuggestMakeNewCategoryCellViewMdoel(collection.query, colorCode)] + cvms
        }
        
        return Observable
            .combineLatest(suggestedResult,
                           self.subjects.selectedMap,
                           self.subjects.randColorCode)
            .map(asCellViewModels)
            .distinctUntilChanged { $0.map { $0.customCompareKey } == $1.map { $0.customCompareKey } }
    }
    
    public var selectedCellViewModels: Observable<[SuggestingCategoryCellViewModel]> {
        return self.subjects.selectedMap
            .map{ $0.cellViewModels }
            .distinctUntilChanged{ $0.map{ $0.customCompareKey } == $1.map{ $0.customCompareKey } }
    }
    
    public var confirmActionTitleBySelectedCount: Observable<String> {
        
        let asCountTitle: (Int) -> String = { count in
            return "Confirm Select %d item(s)".localized(with: count)
        }
        return self.subjects.selectedMap
            .map { $0.count }
            .distinctUntilChanged()
            .map(asCountTitle)
    }
    
    public var clearText: Observable<Void> {
        return self.subjects.clearText
            .asObservable()
    }
    
    public var isProcessing: Observable<Bool> {
        return .empty()
    }
    
    public var scrollToLastSelectionSection: Observable<Int> {
        return self.subjects.scrollToLastSelectionSection
            .asObservable()
    }
}


private extension Array where Element == ItemCategory {
    
    func asCellViewModel(without selectedMap: SelectedCellMap) -> [SuggestingCategoryCellViewModel] {
        return self.map { .init($0) }
            .filter { selectedMap[$0.uid] == nil }
    }
}


private struct SelectedCellMap {
    
    private var index: Int = 0
    private var internalStorage: [String: (Int, SuggestingCategoryCellViewModel)] = [:]
    
    private var appendedNameSet: Set<String> = []
    
    init() { }
    
    subscript(_ k: String) -> SuggestingCategoryCellViewModel? {
        get {
            return self.internalStorage[k]?.1
        }
        set {
            guard let newValue = newValue else {
                self.removeName(k)
                self.internalStorage[k] = nil
                return
            }
            self.index += 1
            self.internalStorage[k] = (self.index, newValue)
            self.appendName(newValue.name)
        }
    }
    
    private mutating func appendName(_ name: String) {
        self.appendedNameSet.insert(name)
    }
    
    private mutating func removeName(_ k: String) {
        guard let name = self.internalStorage[k]?.1.name else { return }
        self.appendedNameSet.remove(name)
    }
    
    func isExists(_ uid: String) -> Bool {
        return self.internalStorage[uid] != nil
    }
    
    func isSelected(_ name: String) -> Bool {
        return self.appendedNameSet.contains(name)
    }
    
    var count: Int {
        return self.internalStorage.count
    }
    
    var cellViewModels: [SuggestingCategoryCellViewModel] {
        return self.internalStorage.values.sorted(by: { $0.0 < $1.0 }).map{ $0.1 }
    }
}

private extension SuggestCategoryCollection {
    
    static func defaultList(_ categories: [ItemCategory], for query: String?) -> SuggestCategoryCollection {
        let suggestCategories = categories.map { SuggestCategory(ownerID: nil, category: $0, lastUpdated: 0) }
        return self.init(query: query ?? "", categories: suggestCategories, cursor: nil)
    }
    
    func isNotFoundQueryMatchingItem() -> Bool {
        return self.query.isNotEmpty && self.categories.filter { $0.category.name == self.query }.isEmpty
    }
}
