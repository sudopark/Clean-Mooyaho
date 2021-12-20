//
//  ColorSelectViewController.swift
//  CommonPresenting
//
//  Created sudo.park on 2021/10/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

import Prelude
import Optics


final class ColorCell: BaseTableViewCell, Presenting {
    
    let codeLabel = UILabel()
    let colorView = UIView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: ColorCellViewMdoel) {
        self.codeLabel.text = cellViewModel.hextCode
        self.colorView.backgroundColor = UIColor.from(hex: cellViewModel.hextCode)
        self.accessoryType = cellViewModel.isSelected ? .checkmark : .none
    }
    
    func setupLayout() {
        
        self.addSubview(colorView)
        colorView.autoLayout.fill(self)
        
        self.contentView.addSubview(codeLabel)
        codeLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
    }
    
    func setupStyling() {
        
        self.tintColor = .white
        
        _ = self.codeLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.textColor .~ UIColor.white
    }
}


// MARK: - ColorSelectViewController

public final class ColorSelectViewController: BaseViewController, ColorSelectScene, BottomSlideViewSupporatble {
    
    public let bottomSlideMenuView: BaseBottomSlideMenuView = .init()
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    private let confirmButton = ConfirmButton()
    
    let viewModel: ColorSelectViewModel
    private var cellViewModels: [ColorCellViewMdoel] = []
    
    public init(viewModel: ColorSelectViewModel) {
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
    
    public func requestCloseScene() {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - bind

extension ColorSelectViewController: UITableViewDataSource, UITableViewDelegate {
    
    private func bind() {
        
        self.bottomSlideMenuView.outsideTouchView.rx.addTapgestureRecognizer()
            .subscribe(onNext: { [weak self] _ in
                self?.requestCloseScene()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.confirmButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelect()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.viewModel.cellViewModels
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] cellViewModels in
                self?.cellViewModels = cellViewModels
                self?.tableView.reloadData()
            })
            .disposed(by: self.disposeBag)
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellViewModels.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ColorCell = tableView.dequeueCell()
        self.cellViewModels[safe: indexPath.row].do <| cell.setupCell(_:)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selected = self.cellViewModels[safe: indexPath.row] else { return }
        self.viewModel.selectColor(selected.hextCode)
    }
}

// MARK: - setup presenting

extension ColorSelectViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.setupBottomSlideLayout()
        
        self.bottomSlideMenuView.containerView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 24)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.numberOfLines = 1
        
        bottomSlideMenuView.containerView.addSubview(self.confirmButton)
        confirmButton.setupLayout(bottomSlideMenuView.containerView)
        
        bottomSlideMenuView.containerView.addSubview(self.tableView)
        tableView.autoLayout.active(with: bottomSlideMenuView.containerView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
            $0.bottomAnchor.constraint(equalTo: confirmButton.topAnchor, constant: -8)
            $0.heightAnchor.constraint(equalToConstant: 300)
        }
    }
    
    public func setupStyling() {
        
        self.bottomSlideMenuView.setupStyling()
        
        _ = self.titleLabel
            |> self.uiContext.decorating.smallHeader
            |> \.text .~ "Select a color"
        
        self.tableView.rowHeight = 75
        self.tableView.registerCell(ColorCell.self)
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.confirmButton.setupStyling()
    }
}
