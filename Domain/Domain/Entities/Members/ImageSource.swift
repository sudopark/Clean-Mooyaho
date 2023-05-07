//
//  ImageSource.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


// MARK: - ImageSource

public struct ImageSize: Equatable, Sendable {
    
    public let width: Double
    public let height: Double
    
    public init(_ width: Double, _ height: Double) {
        self.width = width
        self.height = height
    }
}

public struct ImageSource: Sendable {
    
    public let path: String
    public let size: ImageSize?
    
    public init(path: String, size: ImageSize?) {
        self.path = path
        self.size = size
    }
}


extension ImageSource: Equatable {
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.path == rhs.path
    }
}

// MARK: - ImageSource upload req params

public enum ImageUploadReqParams: Equatable {
    case data(_ value: Data, extension: String, size: ImageSize)
    case file(_ path: String, needCopyTemp: Bool, size: ImageSize)
    case emoji(_ value: String)
}


// MARK: - Thumbnail

public enum Thumbnail: Sendable {
    
    case imageSource(ImageSource)
    case emoji(_ value: String)
}

extension Thumbnail: Equatable {
    
    public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.imageSource(s1), .imageSource(s2)): return s1 == s2
        case let (.emoji(v1), .emoji(v2)): return v1 == v2
        default: return false
        }
    }
}

// MARK: - MemberThubnail and ReactionIcon

public typealias MemberThumbnail = Thumbnail
public typealias ReactionIcon = Thumbnail
