//
//  MemberJSON.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/05/02.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import Domain

public enum DataModels {
    
    public struct Icon {
        
        public let path: String?
        public let externals: (path: String, description: String?)?
        
        public init(path: String) {
            self.path = path
            self.externals = nil
        }
        
        public init(external path: String, description: String?) {
            self.path = nil
            self.externals = (path, description)
        }
    }
    
    public struct Member {
        
        public let uid: String
        public var nickName: String?
        public var icon: Icon?
        
        public init(uid: String, nickName: String? = nil, icon: Icon? = nil) {
            self.uid = uid
            self.nickName = nickName
            self.icon = icon
        }
    }
    
}
//
//// MARK: - mapping member json
//
//public typealias JSON = [String: Any]
//
//extension ImageSource {
//
//    init?(json: JSON) {
//
//        if let pathValue = json["path"] as? String {
//            self = .path(pathValue)
//        } else if let referenceJson = json["reference"] as? [String: Any],
//                  let pathValue = referenceJson["path"] as? String {
//            let description = referenceJson["description"] as? String
//            self = .reference(pathValue, description: description)
//        } else {
//            return nil
//        }
//    }
//}
//

extension ImageSource {
    
    init?(model: DataModels.Icon) {
        if let path = model.path {
            self = .path(path)
        } else if let external = model.externals {
            self = .reference(external.path, description: external.description)
        } else {
            return nil
        }
    }
}
extension Member {

    init(model: DataModels.Member) {
        self.init(uid: model.uid)
        self.nickName = model.nickName
        self.icon = model.icon.flatMap(ImageSource.init(model:))
    }
}
