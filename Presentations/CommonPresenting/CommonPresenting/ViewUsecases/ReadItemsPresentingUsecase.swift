//
//  ReadItemsPresentingUsecase.swift
//  CommonPresenting
//
//  Created by sudo.park on 2021/10/15.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain


// MARK: - ReadItemCellViewModel

public protocol ReadItemCellViewModel {
    var uid: String { get }
    
    var presetingID: Int { get }
    var categories: [ItemCategory] { get set }
}

extension ReadItemCellViewModel {
    
    public var categories: [ItemCategory] {
        get { [] } set { }
    }
}

public protocol ReadItemCellViewModelFactory {
    
    associatedtype Item: ReadItem
    
    init(item: Item)
}

public protocol ReadItemCellViewModelType: ReadItemCellViewModel, ReadItemCellViewModelFactory { }


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
