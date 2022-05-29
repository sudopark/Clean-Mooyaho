//
//  SettingMainViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/11/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SwiftUI

import Domain
import CommonPresenting


// MARK: - SettingMainViewController

public final class SettingMainViewController: UIHostingController<SettingMainView>, SettingMainScene, BaseViewControllable {
    
    let viewModel: SettingMainViewModel
    
    public init(viewModel: SettingMainViewModel) {
        self.viewModel = viewModel
        
        let settingView = SettingMainView(viewModel: viewModel)
        super.init(rootView: settingView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}
