//
//  
//  ManageCategoryViewController.swift
//  SettingScene
//
//  Created by sudo.park on 2022/02/18.
//
//


import UIKit
import SwiftUI

import Domain
import CommonPresenting


// MARK: - ManageCategoryViewController

public final class ManageCategoryViewController: UIHostingController<ManageCategoryView>, ManageCategoryScene, BaseViewControllable {
    
    let viewModel: ManageCategoryViewModel
    
    public init(viewModel: ManageCategoryViewModel) {
        self.viewModel = viewModel
        
        let rootView = ManageCategoryView(viewModel: viewModel)
        super.init(rootView: rootView)
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
