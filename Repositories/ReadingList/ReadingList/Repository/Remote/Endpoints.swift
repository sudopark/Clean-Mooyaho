//
//  Endpoints.swift
//  ReadingList
//
//  Created by sudo.park on 2022/07/31.
//

import Foundation

import Remote

enum ReadingListEndpoints: RestAPIEndpoint {
    
    case list(_ id: String)
    case lists
    case saveList
    case updateList(_ id: String)
    case removeList(_ id: String)
    case linkItem(_ id: String)
    case linkItems
    
    var path: String {
        switch self {
        case .list(let id),
             .updateList(let id),
             .removeList(let id):
            return "reading_list/\(id)"
            
        case .lists, .saveList:
            return "reading_list"
            
        case .linkItem(let id):
            return "reading_list/link_item/\(id)"
            
        case .linkItems:
            return "reading_list/link_items"
        }
    }
    
    var method: HttpAPIMethod {
        switch self {
        case .list, .lists, .linkItem, .linkItems: return .get
        case .saveList: return .post
        case .updateList: return .put
        case .removeList: return .delete
        }
    }
}
