//
//  EditProfileViewController.swift
//  MemberScenes
//
//  Created sudo.park on 2021/05/30.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - EditProfileScene

public protocol EditProfileScene: Scenable { }


// MARK: - EditProfileViewController

public final class EditProfileViewController: BaseViewController, EditProfileScene {
    
    private let viewModel: EditProfileViewModel
    
    let editView = EditProfileView()
    
    public init(viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func loadView() {
        super.loadView()
        self.setupLayout()
        self.setupStyling()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.bind()
    }
    
}

// MARK: - bind

extension EditProfileViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension EditProfileViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(editView)
        editView.autoLayout.activeFill(self.view)
        editView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        editView.setupStyling()
    }
}


// MARK: - tablview dataSource and delegate

extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: EditProfileView.InputTextCell = tableView.dequeueCell()
        return cell
    }
}
