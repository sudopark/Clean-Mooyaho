//
//  Endpoints.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/31.
//

import Foundation

import Remote

public enum ReadingListEndpoints: RestAPIEndpoint {
    
    case list(_ id: String)
    case lists
    case saveList
    case updateList(_ id: String)
    case removeList(_ id: String)
    case linkItem(_ id: String)
    case linkItems
    case saveLinkItem
    case updateLinkItem(_ id: String)
    case removeLinkItem(_ id: String)
    case favoriteItemIDs
    case updateFavoriteItemIDs
    
    public var path: String {
        switch self {
        case .list(let id),
             .updateList(let id),
             .removeList(let id):
            return "reading_list/\(id)"
            
        case .lists, .saveList:
            return "reading_list"
            
        case .linkItem(let id),
             .updateLinkItem(let id),
             .removeLinkItem(let id):
            return "reading_list/link_item/\(id)"
            
        case .linkItems,
             .saveLinkItem:
            return "reading_list/link_items"
            
        case .favoriteItemIDs,
             .updateFavoriteItemIDs:
            return "reading_list/favorites"
        }
    }
    
    public var method: HttpAPIMethod {
        switch self {
        case .list, .lists, .linkItem, .linkItems, .favoriteItemIDs: return .get
        case .saveList, .saveLinkItem: return .post
        case .updateList, .updateLinkItem: return .put
        case .removeList, .removeLinkItem: return .delete
        case .updateFavoriteItemIDs: return .patch
        }
    }
}
