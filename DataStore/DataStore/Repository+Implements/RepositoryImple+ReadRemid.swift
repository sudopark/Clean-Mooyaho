//
//  RepositoryImple+ReadRemid.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/23.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadRemidRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var remindRemote: ReadRemindRemote { get }
    var remindLocal: ReadRemindLocalStorage { get }
}


extension ReadRemindRepository where Self: ReadRemidRepositoryDefImpleDependency {
    
    public func requestLoadReadReminds(for itemIDs: [String]) -> Observable<[ReadRemind]> {
        let remindsInLocal = self.remindLocal.fetchReadReminds(for: itemIDs)
        let remindsInRemote = self.remindRemote.requestLoadReminds(for: itemIDs)
        return remindsInLocal.catchAndReturn([]).asObservable()
            .concat(remindsInRemote)
    }
    
    public func requestScheduleReadRemind(_ readRemind: ReadRemind) -> Maybe<Void> {
        let updateInRemote = self.remindRemote.requestUpdateReimnd(readRemind)
        let updateInLocal = { [weak self] in self?.remindLocal.updateReadRemind(readRemind) ?? .empty() }
        return updateInRemote.switchOr(append: updateInLocal, witoutError: ())
    }
    
    public func requestCancelReadRemind(for uid: String) -> Maybe<Void> {
        let removeInRemote = self.remindRemote.requestRemoveRemind(remindID: uid)
        let removeInLocal = { [weak self] in self?.remindLocal.removeReadRemind(for: uid) ?? .empty() }
        return removeInRemote.switchOr(append: removeInLocal, witoutError: ())
    }
}
