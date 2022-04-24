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


public final class ReadPrioritySelectViewModelImple: BaseEditReadPriorityViewModelImple {
    
    private let startWith: ReadPriority?
    
    public init(startWithSelect: ReadPriority?,
                router: EditReadPriorityRouting,
                listener: ReadPrioritySelectListenable?) {
        self.startWith = startWithSelect
        super.init(router: router, listener: listener)
    }
    
    override var startWithSelect: ReadPriority? { self.startWith }
    
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
