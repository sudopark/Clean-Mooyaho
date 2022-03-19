//
//  NavigateAndChageItemParentViewModel.swift
//  ReadItemScene
//
//  Created by sudo.park on 2021/10/30.
//

import Foundation

import RxSwift
import Prelude
import Optics

import Domain
import CommonPresenting


@available(*, deprecated, message: "사용하는 부분 없음")
public class NavigateAndChageItemParentViewModelImple: NavigateCollectionViewModelImple {
    
    private let targetItem: ReadItem
    private let currentCollection: ReadCollection?
    
    public init(targetItem: ReadItem,
                currentCollection: ReadCollection?,
                unselectableCollectionID: String?,
                readItemUsecase: ReadItemUsecase,
                router: NavigateCollectionRouting,
                coordinator: CollectionInverseNavigationCoordinating?) {
        self.targetItem = targetItem
        self.currentCollection = currentCollection
        super.init(currentCollection: currentCollection,
                   unselectableCollectionID: unselectableCollectionID,
                   readItemUsecase: readItemUsecase,
                   router: router,
                   listener: nil,
                   coordinator: coordinator)
    }
    
    public override func confirmSelect() {
        
        let newParentID = self.currentCollection?.uid
        
        let handleError: (Error) -> Void = { [weak self] error in
            self?.router.alertError(error)
        }
        
        let closeScene: () -> Void = { [weak self] in
            self?.router.closeScene(animated: true, completed: nil)
        }
        
        let params: ReadItemUpdateParams = .init(item: self.targetItem)
            |> \.updatePropertyParams .~ [.parentID(newParentID)]
        
        self.readItemUsecase.updateItem(params)
            .subscribe(onSuccess: closeScene, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public override var isParentChangable: Bool {
        return self.targetItem.parentID != self.currentCollection?.uid
    }
}
