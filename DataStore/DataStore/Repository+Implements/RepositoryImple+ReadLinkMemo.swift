//
//  RepositoryImple+ReadLinkMemo.swift
//  DataStore
//
//  Created by sudo.park on 2021/10/24.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift

import Domain


public protocol ReadLinkMemoRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var memoRemote: ReadLinkMemoRemote { get }
    var memoLocal: ReadLinkMemoLocalStorage { get }
}


extension ReadLinkMemoRepository where Self: ReadLinkMemoRepositoryDefImpleDependency {
    
    public func requestLoadMemo(for linkItemID: String) -> Observable<ReadLinkMemo?> {
        let memoInLocal = self.memoLocal.fetchMemo(for: linkItemID)
        let memoInRemote = self.memoRemote.requestLoadMemo(for: linkItemID)
        return memoInLocal.catchAndReturn(nil).asObservable()
            .concat(memoInRemote)
    }
    
    public func requestUpdateMemo(_ memo: ReadLinkMemo) -> Maybe<Void> {
        let updateInRemote = self.memoRemote.requestUpdateMemo(memo)
        let updateInLocal = { [weak self] in self?.memoLocal.updateMemo(memo) ?? .empty() }
        return updateInRemote.switchOr(append: updateInLocal, witoutError: ())
    }
    
    public func requestRemoveMemo(for linkItemID: String) -> Maybe<Void> {
        let removeInRemote = self.memoRemote.requestDeleteMemo(for: linkItemID)
        let removeInLocal = { [weak self] in self?.memoLocal.deleteMemo(for: linkItemID) ?? .empty() }
        return removeInRemote.switchOr(append: removeInLocal, witoutError: ())
    }
}
