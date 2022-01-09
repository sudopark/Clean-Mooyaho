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
    var hoorayRemote: HoorayRemote { get }
    var hoorayLocal: HoorayLocalStorage { get }
}

extension HoorayRepository where Self: HoorayRepositoryDefImpleDependency {
    
    public func fetchLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {

        return self.hoorayLocal.fetchLatestHooray(for: memberID)
            .map{ $0?.asLatestHooray() }
    }
    
    public func requestLoadLatestHooray(_ memberID: String) -> Maybe<LatestHooray?> {
        
        let saveHoorayIfPossible: (Hooray?) -> Void = { [weak self] hooray in
            guard let hooray = hooray else { return }
            self?.saveHoorays([hooray])
        }
        
        return self.hoorayRemote.requestLoadLatestHooray(memberID)
            .do(onNext: saveHoorayIfPossible)
            .map{ $0?.asLatestHooray() }
    }
    
    public func requestPublishHooray(_ newForm: NewHoorayForm,
                                     withNewPlace: NewPlaceForm?) -> Maybe<Hooray> {
        
        return self.hoorayRemote.requestPublishHooray(newForm, withNewPlace: withNewPlace)
            .do(onNext: { [weak self] hooray in
                self?.saveHoorays([hooray])
            })
    }
    
    public func requestLoadNearbyRecentHoorays(at location: Coordinate) -> Maybe<[Hooray]> {
        
        let saveHoorays: ([Hooray]) -> Void = { [weak self] hoorays in
            self?.saveHoorays(hoorays)
        }
        
        return self.hoorayRemote.requestLoadNearbyRecentHoorays(at: location)
            .do(onNext: saveHoorays)
    }
    
    public func requestAckHooray(_ acks: [HoorayAckMessage]) {
        self.hoorayRemote.requestAckHooray(acks)
    }
    
    private func saveHoorays(_ hoorays: [Hooray]) {
        self.hoorayLocal.saveHoorays(hoorays)
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    public func requestLoadHooray(_ id: String) -> Maybe<Hooray> {
        
        let checkExists: (Hooray?) throws -> Hooray = { hooray in
            guard let hooray = hooray else {
                throw RemoteErrors.notFound("Hooray", reason: nil)
            }
            return hooray
        }
        
        let saveHooray: (Hooray) -> Void = { [weak self] hooray in
            self?.saveHoorays([hooray])
        }
        return self.hoorayRemote.requestLoadHooray(id)
            .map(checkExists)
            .do(onNext: saveHooray)
    }
    
    public func fetchHoorayDetail(_ id: String) -> Maybe<HoorayDetail?> {
        return self.hoorayLocal.fetchHoorayDetail(id)
    }
    
    public func requestLoadHoorayDetail(_ id: String) -> Maybe<HoorayDetail> {

        let loadDetailFromRemote = self.hoorayRemote.requestLoadHoorayDetail(id)
        let thenUpdateLocal: (HoorayDetail) -> Void = { [weak self] detail in
            guard let self = self else { return }
            self.hoorayLocal.saveHoorayDetail(detail)
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        return loadDetailFromRemote
            .do(onNext: thenUpdateLocal)
    }
}


private extension Hooray {
    
    func asLatestHooray() -> LatestHooray {
        return LatestHooray(self.uid, self.timeStamp)
    }
}
