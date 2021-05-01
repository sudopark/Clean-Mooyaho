//
//  Local.swift
//  DataStore
//
//  Created by ParkHyunsoo on 2021/04/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol Local: AuthLocal { }


public protocol AuthLocal {
    
    func saveSignedIn(member: Member) -> Maybe<Void>
}
