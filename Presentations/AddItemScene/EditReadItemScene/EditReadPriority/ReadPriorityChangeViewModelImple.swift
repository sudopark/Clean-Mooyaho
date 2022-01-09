//
//  ReadPriorityChangeViewModelImple.swift
//  EditReadItemScene
//
//  Created by sudo.park on 2021/10/05.
//

import Foundation

import RxSwift
import RxRelay
import Prelude
import Optics

import Domain
import CommonPresenting


public final class ReadPriorityChangeViewModelImple: BaseEditReadPriorityViewModelImple {
    
    private let item: ReadItem
    private let updateUsecase: ReadItemUpdateUsecase
    
    public init(item: ReadItem,
                updateUsecase: ReadItemUpdateUsecase,
                router: EditReadPriorityRouting,
                listener: ReadPriorityUpdateListenable?) {
        self.item = item
        self.updateUsecase = updateUsecase
        super.init(router: router, listener: listener)
    }
    
    override var startWithSelect: ReadPriority? { self.item.priority }
    
    public override func confirmSelect() {
        
        guard let newOne = self.subjects.selectedPriority.value,
              newOne != self.startWithSelect else {
            self.router.closeScene(animated: true, completed: nil)
            return
        }
        
        self.updateItemPriority(newOne)
    }
}


extension ReadPriorityChangeViewModelImple {
        
    func updateItemPriority(_ priority: ReadPriority) {
        
        guard self.subjects.isProcessing.value == false else { return }
        
        let onUpdated: (ReadItem) -> Void = { [weak self] newItem in
            self?.subjects.isProcessing.accept(false)
            self?.closeAndSendUpdateMessage(priority, for: newItem)
        }
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isProcessing.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isProcessing.accept(true)
        self.updatingAction(with: priority)
            .subscribe(onSuccess: onUpdated, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    private func updatingAction(with priority: ReadPriority) -> Maybe<ReadItem> {
        switch self.item {
        case let collection as ReadCollection:
            let newCollection = collection |> \.priority .~ priority
            return self.updateUsecase.updateCollection(newCollection).map { newCollection }
            
        case let readlink as ReadLink:
            let newLink = readlink |> \.priority .~ priority
            return self.updateUsecase.updateLink(newLink).map { newLink }
            
        default: return .just(self.item)
        }
    }
    
    private var updateListener: ReadPriorityUpdateListenable? {
        return self.listener as? ReadPriorityUpdateListenable
    }
    
    private func closeAndSendUpdateMessage(_ priority: ReadPriority, for item: ReadItem) {
        self.router.closeScene(animated: true) { [weak self] in
            self?.updateListener?.editReadPriority(didUpdate: priority, for: item)
        }
    }
}
