//
//  Auth+Mapping.swift
//  FirebaseService
//
//  Created by sudo.park on 2021/05/09.
//

import Foundation


import Domain
import DataStore


// MARK: - Map ImageSource

enum ImageSourceMappingKey: String, JSONMappingKeys {
    case path
    case width = "w"
    case height = "h"
}

extension ImageSource: JSONMappable {
    
    fileprivate typealias Key = ImageSourceMappingKey
    
    init?(json: JSON) {
        guard let path = json[Key.path] as? String else { return nil }
        if let width = json[Key.width] as? Double,
           let height = json[Key.height] as? Double {
            self.init(path: path, size: .init(width, height))
        } else {
            self.init(path: path, size: nil)
        }
    }
    
    func asJSON() -> JSON {
        var json = JSON()
        json[Key.path] = self.path
        json[Key.width] = self.size?.width
        json[Key.height] = self.size?.height
        return json
    }
}


enum ThumbnailMappingKey: String, JSONMappingKeys {
    case isEmoji
    case source
    case emoji
}

extension Thumbnail: JSONMappable {
    
    private typealias Key = ThumbnailMappingKey
    
    init?(json: JSON) {
        let isEmoji = json[Key.isEmoji] as? Bool ?? false
        if isEmoji, let emoji = json[Key.emoji] as? String {
            self = .emoji(emoji)
        } else if let sourceJson = json[Key.source] as? JSON,
                  let source = ImageSource(json: sourceJson) {
            self = .imageSource(source)
        } else {
            return nil
        }
    }
    
    func asJSON() -> JSON {
        switch self {
        case let .emoji(value):
            return [
                Key.isEmoji.rawValue: true,
                Key.emoji.rawValue: value
            ]
        case let .imageSource(source):
            return [
                Key.isEmoji.rawValue: false,
                Key.source.rawValue: source.asJSON()
            ]
        }
    }
}

// MARK: - map memebr

enum MemberMappingKey: String, JSONMappingKeys {
    case nicknanme = "nm"
    case icon
    case introduction = "intro"
}

extension Member: DocumentMappable {
    
    fileprivate typealias Key = MemberMappingKey
    
    init?(docuID: String, json: JSON) {
        self.init(uid: docuID)
        self.nickName = json[Key.nicknanme] as? String
        self.icon = (json[Key.icon] as? JSON).flatMap(Thumbnail.init(json:))
        self.introduction = json[Key.introduction] as? String
    }
    
    func asDocument() -> (String, JSON) {
        var json = JSON()
        json[Key.nicknanme] = self.nickName
        json[Key.icon] = self.icon?.asJSON
        json[Key.introduction] = self.introduction
        return (self.uid, json)
    }
}

