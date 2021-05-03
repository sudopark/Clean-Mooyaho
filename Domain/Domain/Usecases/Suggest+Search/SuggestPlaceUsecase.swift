//
//  SuggestPlaceUsecase.swift
//  Domain
//
//  Created by ParkHyunsoo on 2021/05/04.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift


public protocol SuggestPlaceUsecase { }


public final class SuggestPlaceUsecaseImple {
    
    private let placeRepository: PlaceRepository
    public init(placeRepository: PlaceRepository) {
        self.placeRepository = placeRepository
    }
    
    
    private let disposeBag: DisposeBag = DisposeBag()
}

extension SuggestPlaceUsecaseImple {
    
    
    
}
