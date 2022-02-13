//
//  
//  ManageAccountViewController.swift
//  SettingScene
//
//  Created by sudo.park on 2022/02/13.
//
//


import UIKit
import SwiftUI

import Domain
import CommonPresenting


// MARK: - ManageAccountViewController

public final class ManageAccountViewController: UIHostingController<ManageAccountView>, ManageAccountScene, BaseViewControllable {

    let viewModel: ManageAccountViewModel

    public init(viewModel: ManageAccountViewModel) {
        self.viewModel = viewModel

        let rootView = ManageAccountView(viewModel: viewModel)
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
