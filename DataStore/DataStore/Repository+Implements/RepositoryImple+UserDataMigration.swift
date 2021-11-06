//
//  RepositoryImple+UserDataMigration.swift
//  DataStore
//
//  Created by sudo.park on 2021/11/06.
//  Copyright © 2021 ParkHyunsoo. All rights reserved.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain


public protocol UserDataMigrationRepositoryDefImpleDependency: AnyObject {
    
    var disposeBag: DisposeBag { get }
    var migrateLocal: UserDataMigratableLocalStorage & DataModelStorageSwitchable { get }
    var migrateRemote: BatchUploadRemote { get }
}


extension UserDataMigrateRepository where Self: UserDataMigrationRepositoryDefImpleDependency {
    
    public func checkMigrationNeed() -> Maybe<Bool> {
        return .just(self.migrateLocal.checkHasAnonymousStorage())
    }
    
    public func requestMoveReadItemCategories(for userID: String) -> Observable<[ItemCategory]> {
        
        return self.recursiveMoving(with: { $0 |> \.ownerID .~ userID }, idSelector: { $0.uid })
    }
    
    public func requestMoveReadItems(for userID: String) -> Observable<[ReadItem]> {
        
        return self.recursiveMoving(with: { $0 |> \.ownerID .~ userID }, idSelector: { $0.uid })
    }
    
    public func requestMoveReadLinkMemos(for userID: String) -> Observable<[ReadLinkMemo]> {
        return self.recursiveMoving(with: { $0 |> \.ownerID .~ userID }, idSelector: { $0.linkItemID })
    }
    
    private func move<E>(with mutate: @escaping (E) -> E = { $0 },
                         idSelector: @escaping (E) -> String) -> Maybe<[E]> {
        let fetching = self.migrateLocal.fetchFromAnonymousStorage(E.self, size: 50)
        let finishStreamWhenEmpty: ([E]) -> Maybe<[E]> = { items in
            return items.isEmpty ? .empty() : .just(items)
        }
        
        let mutateElements: ([E]) -> [E] = { items in
            return items.map(mutate)
        }
                
        let thenBatchUpload: ([E]) -> Maybe<[E]> = { [weak self] items in
            guard let self = self else { return .empty() }
            return self.migrateRemote.requestBatchUpload(E.self, data: items).map { items }
        }
        
        let thenRemoveFromAnonymousStorage: ([E]) -> Maybe<[E]> = { [weak self] items in
            guard let self = self else { return .empty() }
            let ids = items.map(idSelector)
            return self.migrateLocal.removeFromAnonymousStorage(E.self, in: ids).map { items }
        }
        let thenCopyToUserStorage: ([E]) -> Maybe<[E]> = { [weak self] items in
            guard let self = self else { return .empty() }
            return self.migrateLocal.saveToUserStorage(E.self, items).map { items }
        }
        
        return fetching
            .flatMap(finishStreamWhenEmpty)
            .map(mutateElements)
            .flatMap(thenBatchUpload)
            .flatMap(thenRemoveFromAnonymousStorage)
            .flatMap(thenCopyToUserStorage)
    }
    
    private func recursiveMove<E>(under scope: DisposeBag!,
                                  with mutate: @escaping (E) -> E = { $0 },
                                  idSelector: @escaping (E) -> String,
                                  didMoved: @escaping ([E]) -> Void,
                                  completed: @escaping (Result<Void, Error>) -> Void) {
        
        guard let scope = scope else { return }
        
        let onMoved: ([E]) -> Void = { [weak self, weak scope] elements in
            guard let self = self, let scope = scope
            else {
                completed(.success(()))
                return
            }
            
            didMoved(elements)
            self.recursiveMove(under: scope,
                               with: mutate, idSelector: idSelector,
                               didMoved: didMoved, completed: completed)
                
        }
        let onError: (Error) -> Void = { error in
            completed(.failure(error))
        }
        
        let onCompleted: () -> Void = {
            completed(.success(()))
        }
        self.move(with: mutate, idSelector: idSelector)
            .subscribe(onSuccess: onMoved, onError: onError, onCompleted: onCompleted)
            .disposed(by: scope)
    }
    
    private func recursiveMoving<E>(with mutate: @escaping (E) -> E = { $0 },
                                    idSelector: @escaping (E) -> String) -> Observable<[E]> {
        return Observable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            var disposeBag: DisposeBag! = DisposeBag()
            let didMoved: ([E]) -> Void = { elements in
                observer.onNext(elements)
            }
            
            let didCompleted: (Result<Void, Error>) -> Void = { result in
                switch result {
                case .success:
                    observer.onCompleted()
                    
                case let .failure(error):
                    observer.onError(error)
                }
            }
            
            self.recursiveMove(under: disposeBag,
                               with: mutate, idSelector: idSelector,
                               didMoved: didMoved, completed: didCompleted)
            return Disposables.create {
                disposeBag = nil
            }
        }
    }
    
    public func clearMigrationNeedData() -> Maybe<Void> {
        return self.migrateLocal.removeAnonymousStorage()
    }
}
