//
//  SuggestPlaceViewController.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/05/28.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SuggestPlaceScene

public protocol SuggestPlaceScene: Scenable { }


// MARK: - SuggestPlaceViewController

public final class SuggestPlaceViewController: BaseViewController, SuggestPlaceScene {
    
    private let suggestView = SuggestPlaceView()
    private let viewModel: SuggestPlaceViewModel
    
    public init(viewModel: SuggestPlaceViewModel) {
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

extension SuggestPlaceViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.suggestView.tableView.register(DummyCell.self, forCellReuseIdentifier: "dummy")
        self.suggestView.tableView.estimatedRowHeight = 80
        self.suggestView.tableView.dataSource = self
        self.suggestView.tableView.delegate = self
        self.suggestView.tableView.reloadData()
    }
}

// MARK: - setup presenting

extension SuggestPlaceViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(suggestView)
        suggestView.autoLayout.activeFill(self.view)
        self.suggestView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.suggestView.setupStyling()
    }
}


// MARK: - test setup tableview

class DummyCell: UITableViewCell {
    
    let numLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.addSubview(numLabel)
        numLabel.autoLayout.active {
            $0.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
        }
        numLabel.textColor = .black
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension SuggestPlaceViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dummy") as! DummyCell
        cell.numLabel.text = "num: \(indexPath.row)"
        return cell
    }
}
