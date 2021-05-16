//
//  RepositoryImple+Hooray.swift
//  DataStore
//
//  Created by sudo.park on 2021/05/16.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol HoorayRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var remote: HoorayRemote { get }
    var local: HoorayLocalStorage { get }
}

extension HoorayRepository where Self: HoorayRepositoryDefImpleDependency {
    
    func fetchLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {

        return self.local.fetchLatestHooray(for: memberID)
            .map{ $0?.asLatestHooray() }
    }
    
    public func requestLoadLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {
        
        let saveHoorayIfPossible: (Hooray?) -> Void = { [weak self] hooray in
            guard let hooray = hooray else { return }
            self?.saveHoorays([hooray])
        }
        
        return self.remote.requestLoadLatestHooray(memberID)
            .do(onNext: saveHoorayIfPossible)
            .map{ $0?.asLatestHooray() }
    }
    
    public func requestPublishHooray(_ newForm: NewHoorayForm,
                                     withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        
        return self.remote.requestPublishHooray(newForm, withNewPlace: withNewPlace)
            .do(onNext: { [weak self] hooray in
                self?.saveHoorays([hooray])
            })
    }
    
    public func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        return self.remote.requestLoadNearbyRecentHoorays(at: location)
    }
    
    private func saveHoorays(_ hoorays: [Hooray]) {
        self.local.saveHoorays(hoorays)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}


private extension Hooray {
    
    func asLatestHooray() -> LatestHooray {
        return LatestHooray(self.uid, self.timeStamp)
    }
}
