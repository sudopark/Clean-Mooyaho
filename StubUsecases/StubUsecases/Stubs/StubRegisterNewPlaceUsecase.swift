//
//  StubRegisterNewPlaceUsecase.swift
//  StubUsecases
//
//  Created by sudo.park on 2021/06/12.
//

import Foundation

import RxSwift

import Domain
import UnitTestHelpKit


open class StubRegisterNewPlaceUsecase: RegisterNewPlaceUsecase, Stubbable {
    
    public init() {}
    
    open func loadRegisterPendingNewPlaceForm(withIn position: Coordinate) -> Maybe<NewPlaceForm?> {
        return self.resolve(key: "loadRegisterPendingNewPlaceForm") ?? .empty()
    }
    
    public func finishInputPlaceInfo(_ form: NewPlaceForm) -> Maybe<NewPlaceForm> {
        return self.resolve(key: "finishInputPlaceInfo") ?? .empty()
    }
    
    public func uploadNewPlace(_ form: NewPlaceForm) -> Maybe<Place> {
        return self.resolve(key: "uploadNewPlace") ?? .empty()
    }
}
