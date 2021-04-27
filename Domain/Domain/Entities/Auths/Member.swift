//
//  Member.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation


public protocol Member {
    
    var isAnonymous: Bool { get }
    
    var memberID: String { get }
    
    var realName: String? { get set }
    
    var nickName: String? { get }
    
    var email: String? { get set }
    
    var imageSource: ImageSource? { get set }
    
    var verifiedPhoneNumber: String? { get set }
}

extension Member {
    
    public var isAnonymous: Bool { false }
}