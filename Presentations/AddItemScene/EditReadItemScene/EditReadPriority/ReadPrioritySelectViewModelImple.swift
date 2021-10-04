//
//  ReadPrioritySelectViewModelImple.swift
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
import Alamofire


public final class ReadPrioritySelectViewModelImple: BaseEditReadPriorityViewModelImple {
    
    private var selectListener: ReadPrioritySelectListenable? {
        return self.listener as? ReadPrioritySelectListenable
    }
    
    public override func confirmSelect() {
        
        let newPriority = self.subjects.selectedPriority.value
        self.router.closeScene(animated: true) { [weak self] in
            guard let listener = self?.selectListener, let new = newPriority else { return }
            listener.editReadPriority(didSelect: new)
        }
    }
}
