//
//  ReadCollectionViewController.swift
//  ReadItemScene
//
//  Created sudo.park on 2021/09/19.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting

// MARK: - ReadCollectionViewController

public final class ReadCollectionViewController: BaseViewController, ReadCollectionScene {
    
    let viewModel: ReadCollectionViewModel
    
    private let collectionView = UICollectionView()
    
    
    public init(viewModel: ReadCollectionViewModel) {
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

extension ReadCollectionViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension ReadCollectionViewController: Presenting {
    
    
    public func setupLayout() {
        
    }
    
    public func setupStyling() {
        
    }
}
