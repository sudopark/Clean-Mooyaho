//
//  SharedMemberListViewController.swift
//  DiscoveryScene
//
//  Created sudo.park on 2022/01/01.
//  Copyright © 2022 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import CommonPresenting

// MARK: - SharedMemberListViewController

public final class SharedMemberListViewController: BaseViewController, SharedMemberListScene, ShrinkableTtileHeaderViewSupporting {
    
    private typealias CVM = SharedMemberCellViewModel
    private typealias Section = SectionModel<String, CVM>
    private typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    public let titleHeaderView = BaseTableViewHeaderView()
    private let tableView = UITableView()
    public var titleHeaderViewRelatedScrollView: UIScrollView { self.tableView }
    
    let viewModel: SharedMemberListViewModel
    private var dataSource: DataSource!
    private let exlcudeActionSubject = PublishSubject<String>()
    
    public init(viewModel: SharedMemberListViewModel) {
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
        self.viewModel.refresh()
    }
    
}

// MARK: - bind

extension SharedMemberListViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
                self?.bindUpdateTitleheaderViewByScroll(with: .just("Shared with".localized))
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModel
            .map { [Section(model: "members", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.showMemberProfile(cellViewModel.memberID)
            })
            .disposed(by: self.disposeBag)
        
        let userDragging = self.tableView.rx.willBeginDragging.take(1)
        self.tableView.rx.scrollBottomHit(wait: userDragging, threshold: 100)
            .debounce(.milliseconds(700), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.loadMore()
            })
            .disposed(by: self.disposeBag)
        
        self.exlcudeActionSubject
            .subscribe(onNext: { [weak self] memberID in
                self?.viewModel.excludeMember(memberID)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        let configureCell: DataSource.ConfigureCell = { [weak self] _, tableView, indexPath, cellViewModel in
            guard let self = self else { return UITableViewCell() }
            let cell: SharedMemberCell = tableView.dequeueCell()
            cell.actionSubject = self.exlcudeActionSubject
            cell.bindCell(memberID: cellViewModel.memberID, source: self.viewModel.memberAttribute(for: cellViewModel.memberID))
            return cell
        }
        return DataSource(configureCell: configureCell)
    }
}

// MARK: - setup presenting

extension SharedMemberListViewController: Presenting {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.topAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.topAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.tableView.tableHeaderView = self.titleHeaderView
        titleHeaderView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: tableView.leadingAnchor)
            $0.widthAnchor.constraint(equalTo: tableView.widthAnchor)
            $0.topAnchor.constraint(equalTo: tableView.topAnchor)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        titleHeaderView.setupLayout()
    }
    
    public func setupStyling() {
        self.view.backgroundColor = self.uiContext.colors.appBackground
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        
        self.tableView.registerCell(SharedMemberCell.self)
        
        self.titleHeaderView.setupStyling()
    }
}


final class SharedMemberCell: BaseTableViewCell, Presenting {
    
    let borderView = UIView()
    let thumbnailImageView = IntegratedImageView()
    let contentStackView = UIStackView()
    let nameLabel = UILabel()
    let introLabel = UILabel()
    let moreButton = UIButton(type: .system)
    
    weak var actionSubject: PublishSubject<String>?
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.thumbnailImageView.cancelSetupImage()
    }
    
    func bindCell(memberID: String, source: Observable<SharedMemberCellViewModel.Attribute>) {
        
        source
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] attribute in
                self?.updateAttribute(attribute)
            })
            .disposed(by: self.disposeBag)
        
        self.moreButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.actionSubject?.onNext(memberID)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateAttribute(_ attribute: SharedMemberCellViewModel.Attribute) {
        self.thumbnailImageView.setupImage(using: attribute.thumbnail, resize: .init(width: 50, height: 50))
        self.nameLabel.text = attribute.name
        self.introLabel.text = attribute.description
        self.introLabel.isHidden = attribute.description?.isNotEmpty != true
    }
}


extension SharedMemberCell {
    
    func setupLayout() {
        
        self.contentView.addSubview(borderView)
        borderView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 40)
            $0.heightAnchor.constraint(equalToConstant: 40)
            $0.topAnchor.constraint(greaterThanOrEqualTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: $1.bottomAnchor, constant: -12)
        }
        
        self.borderView.addSubview(thumbnailImageView)
        thumbnailImageView.autoLayout.fill(borderView, edges: .init(top: 1, left: 1, bottom: 1, right: 1))
        thumbnailImageView.setupLayout()
        
        self.contentView.addSubview(moreButton)
        moreButton.autoLayout.active(with: self.contentView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -20)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        self.contentView.addSubview(contentStackView)
        contentStackView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -12)
            $0.leadingAnchor.constraint(equalTo: borderView.trailingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor, constant: -8)
        }
        contentStackView.axis = .vertical
        
        contentStackView.addArrangedSubview(nameLabel)
        contentStackView.addArrangedSubview(introLabel)
    }
    
    func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.thumbnailImageView.setupStyling()
        self.thumbnailImageView.backgroundColor = self.uiContext.colors.appBackground
        self.thumbnailImageView.layer.cornerRadius = 19
        self.thumbnailImageView.clipsToBounds = true
        
        self.borderView.backgroundColor = self.uiContext.colors.appSecondBackground
        self.borderView.layer.cornerRadius = 20
        self.borderView.clipsToBounds = true
        
        _ = self.nameLabel
            |> { self.uiContext.decorating.listItemTitle($0) }
            |> \.numberOfLines .~ 1
            |> \.text .~ pure("-".localized)
        
        _ = self.introLabel
            |> { self.uiContext.decorating.listItemDescription($0) }
            |> \.numberOfLines .~ 1
            |> \.text .~ pure("-".localized)
            |> \.isHidden .~ true
        
        self.moreButton.setImage(UIImage(systemName: "person.fill.xmark"), for: .normal)
        self.moreButton.imageView?.contentMode = .scaleAspectFit
    }
}
