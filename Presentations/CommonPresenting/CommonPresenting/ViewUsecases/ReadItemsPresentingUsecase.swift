//
//  ReadItemsPresentingUsecase.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/15.
//

import UIKit

import RxSwift
import Prelude
import Optics

import Domain


// MARK: - ReadItemCellViewModel

public protocol ReadItemCellViewModel {
    var uid: String { get }
    
    var presetingID: Int { get }
    var categories: [ItemCategory] { get set }
    var remindTime: TimeStamp? { get set }
    var isFavorite: Bool { get set }
}

extension ReadItemCellViewModel {
    
    public var isFavorite: Bool {
        get { false }
        set { }
    }
}

extension ReadItemCellViewModel {
    
    public var categories: [ItemCategory] {
        get { [] } set { }
    }
    
    public var remindTime: TimeStamp? {
        get { nil } set { }
    }
}

public protocol ReadItemCellViewModelFactory {
    
    associatedtype Item: ReadItem
    
    init(item: Item)
}

public protocol ShrinkableCell {
    var isShrink: Bool { get set }
}

public protocol ReadItemCellViewModelType: ReadItemCellViewModel, ReadItemCellViewModelFactory { }


// MARK: - section

public enum ReadCollectionItemSectionType: String {
    case attribute
    case collections
    case links
}

public struct ReadCollectionItemSection {
    
    public let type: ReadCollectionItemSectionType
    public let cellViewModels: [ReadItemCellViewModel]
    
    public init(type: ReadCollectionItemSectionType, cellViewModels: [ReadItemCellViewModel]) {
        self.type = type
        self.cellViewModels = cellViewModels
    }
}


// MARK: - ReadItemCells

public protocol ReadItemCells: BaseTableViewCell {
    
    associatedtype CellViewModel: ReadItemCellViewModel
    
    func setupCell(_ cellViewModel: CellViewModel)
    
    func updateCategories(_ categories: [ItemCategory])
}


// MARK: - extensions

extension Array where Element: ReadItem {
    
    public func sort(by order: ReadCollectionItemSortOrder, with customOrder: [String]) -> Array {
        let orderMap = customOrder.enumerated().reduce(into: [String: Int]()) { $0[$1.element] = $1.offset }
        
        let compare: (Element, Element) -> Bool = { lhs, rhs in
            switch order {
            case let .byCreatedAt(isAscending):
                return isAscending
                    ? lhs.createdAt < rhs.createdAt
                    : lhs.createdAt > rhs.createdAt
                
            case let .byLastUpdatedAt(isAscending):
                return isAscending
                    ? lhs.lastUpdatedAt < rhs.lastUpdatedAt
                    : lhs.lastUpdatedAt > rhs.lastUpdatedAt
                
            case let .byPriority(isAscending):
                return isAscending
                    ? ReadPriority.isAscendingOrder(lhs.priority, rhs: rhs.priority)
                    : ReadPriority.isDescendingOrder(lhs.priority, rhs: rhs.priority)
                
            case .byCustomOrder:
                let (indexL, indexR) = (orderMap[lhs.uid], orderMap[rhs.uid])
                return indexL.flatMap { idxl in indexR.map { idxl < $0 } ?? false }
                    ?? indexR.map { _ in true }
                    ?? (lhs.createdAt > rhs.createdAt)
                    
            }
        }
        return self.sorted(by: compare)
    }
}

extension Array where Element: ReadItem {
    
    public func asCellViewModels<CVM: ReadItemCellViewModelType>(with categoryMap: [String: ItemCategory]? = nil) -> [CVM] {
                
        let transform: (Element) -> CVM? = { element in
            switch element {
            case let item as CVM.Item:
                return CVM(item: item)
                    |> \.categories .~  (categoryMap.map { map in item.categoryIDs.compactMap{ map[$0]} } ?? [])
                
            default: return nil
            }
        }
        
        return self.compactMap(transform)
    }
}

extension Array where Element: ReadItemCellViewModel {
    
    public func asSectionIfNotEmpty(for type: ReadCollectionItemSectionType) -> ReadCollectionItemSection? {
        guard self.isNotEmpty else { return nil }
        return .init(type: type, cellViewModels: self)
    }
    
    public func updateIsShrinkMode(_ flag: Bool) -> Array where Element: ShrinkableCell {
        return self.map {
            return  $0 |> \.isShrink .~ flag
        }
    }
}
