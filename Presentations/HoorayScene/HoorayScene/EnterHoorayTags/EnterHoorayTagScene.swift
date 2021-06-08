//
//  EnterHoorayTagScene.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/09.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


extension EnterHoorayTagViewModelImple: EnteringNewHoorayPresenter {
    
}

extension EnterHoorayTagViewController {
    
    public var presenter: EnteringNewHoorayPresenter? {
        return self.viewModel as? EnteringNewHoorayPresenter
    }
    
}
