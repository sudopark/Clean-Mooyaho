//
//  
//  ManageAccountView.swift
//  SettingScene
//
//  Created by sudo.park on 2022/02/13.
//
//


import UIKit
import SwiftUI

import RxSwift
import RxCocoa

import Domain
import CommonPresenting


// MARK: - ManageAccountViewController

public final class ManageAccountViewStateObject: ObservableObject {
    
    private let disposeBag = DisposeBag()
    private var didBind = false
    
    public func bind(_ viewModel: ManageAccountViewModel) {
        
        guard self.didBind == false else { return }
        self.didBind = true
        
        // TODO: bind state
    }
}


// MARK: - ManageAccountView

public final class ManageAccountView: View {
    
    private let viewModel: ManageAccountViewModel
    @StateObject var states: ManageAccountViewStateObject = .init()
    
    public init(viewModel: ManageAccountViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Text("ManageAccountView")
        .onAppear {
            self.states.bind(self.viewModel)
        }
    }
}
