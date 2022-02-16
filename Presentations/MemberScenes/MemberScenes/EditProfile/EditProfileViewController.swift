//
//  
//  EditProfileViewController.swift
//  MemberScenes
//
//  Created by sudo.park on 2022/02/16.
//
//


import UIKit
import SwiftUI

import Domain
import CommonPresenting


// MARK: - EditProfileViewController

public final class EditProfileViewController: UIHostingController<EditProfileView>, EditProfileScene, BaseViewControllable {
    
    let viewModel: EditProfileViewModel
    
    public init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        
        let rootView = EditProfileView(viewModel: viewModel)
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
