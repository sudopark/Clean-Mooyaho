//
//  LinkPreview.swift
//  Domain
//
//  Created by sudo.park on 2021/09/19.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public struct LinkPreview {
    
    public let title: String?
    public let description: String?
    public let mainImageURL: String?
    public let iconURL: String?
    
    public init(title: String?, description: String?,
                mainImageURL: String?, iconURL: String?) {
        self.title = title
        self.description = description
        self.mainImageURL = mainImageURL
        self.iconURL = iconURL
    }
}
