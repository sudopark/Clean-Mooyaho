//
//  
//  WaitMigrationViewController.swift
//  SettingScene
//
//  Created by sudo.park on 2022/03/13.
//
//


import UIKit
import SwiftUI

import Domain
import CommonPresenting


// MARK: - WaitMigrationViewController

public final class WaitMigrationViewController: UIHostingController<WaitMigrationView>, WaitMigrationScene, BaseViewControllable {
    
    let viewModel: WaitMigrationViewModel
    
    public init(viewModel: WaitMigrationViewModel) {
        self.viewModel = viewModel
        
        let rootView = WaitMigrationView(viewModel: viewModel)
        super.init(rootView: rootView)
        self.view.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}
