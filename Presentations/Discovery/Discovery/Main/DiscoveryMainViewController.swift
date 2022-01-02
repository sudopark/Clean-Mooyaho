//
//  DiscoveryMainViewController.swift
//  DiscoveryScene
//
//  Created sudo.park on 2021/11/14.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxDataSources
import Prelude
import Optics

import Domain
import CommonPresenting

// MARK: - DiscoveryMainViewController

public final class DiscoveryMainViewController: BaseViewController, DiscoveryMainScene {
    
    typealias CVM = LatestSharedCellViewMdoel
    typealias Section = SectionModel<String, CVM>
    typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private let tableView = UITableView()
    private let switchButton = SwitchToMyCollectionButton()
    private let emptyView = EmptyLatestSharedView()
    
    let viewModel: DiscoveryMainViewModel
    private var dataSource: DataSource!
    private let viewAllCollectionSubject = PublishSubject<Void>()
    
    public init(viewModel: DiscoveryMainViewModel) {
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

extension DiscoveryMainViewController {
    
    private func bind() {
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        self.switchButton.button.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.switchToMyCollection()
            })
            .disposed(by: self.disposeBag)
        
        self.updateSwitchToMyCollectionButtonIsHidden()
        
        self.viewAllCollectionSubject
            .subscribe(onNext: { [weak self] in
                self?.viewModel.viewAllSharedCollections()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateSwitchToMyCollectionButtonIsHidden() {
        guard self.viewModel.showSwitchToMyCollection else { return }
        self.switchButton.isHidden = false
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 50, right: 0)
    }
    
    private func bindTableView() {
        self.dataSource = self.makeDataSource()
        
        self.viewModel.cellViewModels
            .map { [SectionModel(model: "shares", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.tableView.rx.modelSelected(CVM.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.selectCollection(cellViewModel.shareID)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.sharedListIsEmpty
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] isEmpty in
                self?.updateEmptyView(isEmpty)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        
        let configureCell: (DataSource.ConfigureCell) = { [weak self] _, tableView, indexPath, cellViewModel in
            guard let self = self else { return UITableViewCell() }
            let cell: LatestSharedCollectionCell = tableView.dequeueCell()
            cell.setupCell(cellViewModel)
            cell.bindShareOwnerInfo(self.viewModel.shareOwner(for: cellViewModel.shareOwnerID))
            return cell
        }
        return .init(configureCell: configureCell)
    }
    
    private func updateEmptyView(_ isEmpty: SharedListIsEmpty) {
        self.emptyView.descriptionLabel.text = isEmpty.emptyMessage
        self.emptyView.isHidden = isEmpty.isEmpty == false
    }
}

// MARK: - setup presenting

extension DiscoveryMainViewController: Presenting, UITableViewDelegate {
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view, edges: .init(top: 0, left: 12, bottom: 0, right: 12), withSafeArea: true)
        
        self.view.addSubview(switchButton)
        switchButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        switchButton.setupLayout()
        
        self.view.addSubview(emptyView)
        emptyView.autoLayout.fill(self.view, edges: .init(top: 50, left: 0, bottom: 0, right: 0), withSafeArea: true)
        self.emptyView.setupLayout()
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.showsVerticalScrollIndicator = false
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.tableFooterView = nil
        
        self.tableView.registerHeaderFooter(SharedCollectionsHeaderView.self)
        self.tableView.registerCell(LatestSharedCollectionCell.self)
        
        self.switchButton.setupStyling()
        self.switchButton.isHidden = true
        
        self.emptyView.setupStyling()
        self.emptyView.isHidden = true
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionView: SharedCollectionsHeaderView = tableView.dequeueHeaderFooterView()
        sectionView.subject = self.viewAllCollectionSubject
        sectionView.bindViewAll()
        sectionView.bindIsViewAllButtonEnable(viewModel.viewAllSharedListEnable)
        return sectionView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}



// MARK: - subviews

final class SwitchToMyCollectionButton: BaseUIView, Presenting {
    
    let upperLineView = UIView()
    let switchImageView = UIImageView()
    let messageLabel = UILabel()
    fileprivate let button = UIButton()
    
    func setupLayout() {
        self.addSubview(upperLineView)
        upperLineView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 1)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
        }
        
        self.addSubview(switchImageView)
        switchImageView.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        
        self.addSubview(messageLabel)
        messageLabel.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: switchImageView.trailingAnchor, constant: 8)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -8)
        }
        
        self.addSubview(button)
        button.autoLayout.fill(self)
    }
    
    func setupStyling() {
        
        self.backgroundColor = UIColor.from(hex: "#212121")
        
        self.upperLineView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        self.switchImageView.image = UIImage(systemName: "arrow.left.arrow.right.circle")
        self.switchImageView.contentMode = .scaleAspectFit
        self.switchImageView.tintColor = UIColor.link
        
        self.messageLabel.font = self.uiContext.fonts.get(13.5, weight: .regular)
        self.messageLabel.textColor = UIColor.link
        self.messageLabel.text = "Switch to my read collection".localized
        self.messageLabel.numberOfLines = 1
    }
}

final class SharedCollectionsHeaderView: BaseTableViewSectionHeaderFooterView, Presenting {
    
    weak var subject: PublishSubject<Void>?
    let messageLabel = UILabel()
    let viewAllButton = UIButton(type: .system)
    
    private var disposeBag: DisposeBag = .init()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = .init()
    }
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func bindViewAll() {
        
        self.viewAllButton.rx.throttleTap()
            .subscribe(onNext: { [weak self] in
                self?.subject?.onNext()
            })
            .disposed(by: self.disposeBag)
    }
    
    func bindIsViewAllButtonEnable(_ source: Observable<Bool>) {
        source
            .asDriver(onErrorDriveWith: .never())
            .drive(self.viewAllButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(viewAllButton)
        viewAllButton.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
        
        self.contentView.addSubview(messageLabel)
        messageLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 4)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: viewAllButton.leadingAnchor, constant: -8)
        }
    }
    
    func setupStyling() {
        
        self.tintColor = UIColor(red: 30/255, green: 34/255, blue: 40/255, alpha: 1)
        
        _ = self.messageLabel
            |> self.uiContext.decorating.listSectionTitle(_:)
            |> \.numberOfLines .~ 1
            |> \.textColor .~ UIColor.white.withAlphaComponent(0.8)
            |> \.text .~ pure("Shared read collections".localized)
        
        self.viewAllButton.setTitle("View all".localized, for: .normal)
        self.viewAllButton.tintColor = UIColor.systemBlue
        self.viewAllButton.isEnabled = false
    }
}

final class LatestSharedCollectionCell: BaseTableViewCell, Presenting {
    
    private let cellSpacing: CGFloat = 4
    
    let colorBackgroundView = UIView()
    let iconImageView = UIImageView()
    let nameLabel = UILabel()
    let descriptionLabel = UILabel()
    let sharedLabel = UILabel()
    let shareMemberProfileImageView = IntegratedImageView()
    let shareMemberNameLabel = UILabel()
    private var shareMemberTopContraint: NSLayoutConstraint!
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.shareMemberProfileImageView.cancelSetupImage()
    }
    
    func setupCell(_ cellViewModel: LatestSharedCellViewMdoel) {
        self.updateIcon(by: cellViewModel.isFavorite)
        self.updateNameAndDescription(cellViewModel)
        self.accessoryType = cellViewModel.isCurrentCollection ? .checkmark : .none
    }
    
    private func updateIcon(by isFavorite: Bool) {
        let imageName = isFavorite ? "star.fill" : "folder"
        self.iconImageView.image = UIImage(systemName: imageName)
        self.iconImageView.tintColor = isFavorite ? UIColor.systemYellow : UIColor.white
    }
    
    private func updateNameAndDescription(_ cellViewModel: LatestSharedCellViewMdoel) {
        self.nameLabel.text = cellViewModel.collectionName
        
        let validDescription = cellViewModel.description?.emptyAsNil()
        self.descriptionLabel.isHidden = validDescription == nil
        self.shareMemberTopContraint.constant = validDescription == nil ? 6 : 26
        self.descriptionLabel.text = validDescription
    }
    
    func bindShareOwnerInfo(_ source: Observable<Member>) {
        source
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] member in
                self?.updateShareOwnerInfo(member)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateShareOwnerInfo(_ member: Member) {
        self.shareMemberNameLabel.text = member.nickName ?? "Unknown".localized
        self.shareMemberProfileImageView.cancelSetupImage()
        guard let icon = member.icon else { return }
        self.shareMemberProfileImageView.setupImage(using: icon, resize: .init(width: 15, height: 15))
    }
}

extension LatestSharedCollectionCell {
    
    func setupLayout() {
        
        self.addSubview(colorBackgroundView)
        colorBackgroundView.autoLayout.fill(self, edges: .init(top: 0, left: 0, bottom: cellSpacing, right: 0))
        
        self.contentView.addSubview(iconImageView)
        iconImageView.autoLayout.active(with: self.contentView) {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 12)
        }
        
        self.contentView.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        }
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.contentView.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -8)
        }
        
        self.contentView.addSubview(shareMemberProfileImageView)
        shareMemberProfileImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -16-self.cellSpacing)
        }
        shareMemberTopContraint = shareMemberProfileImageView.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 6)
        shareMemberTopContraint.isActive = true
        shareMemberProfileImageView.setupLayout()
        
        self.contentView.addSubview(sharedLabel)
        sharedLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: shareMemberProfileImageView.leadingAnchor, constant: -6)
            $0.centerYAnchor.constraint(equalTo: shareMemberProfileImageView.centerYAnchor)
        }
        sharedLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.contentView.addSubview(shareMemberNameLabel)
        shareMemberNameLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: shareMemberProfileImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: $1.trailingAnchor, constant: -8)
            $0.centerYAnchor.constraint(equalTo: shareMemberProfileImageView.centerYAnchor)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = .clear
        self.setupColorbackgoundViewStyling()
        
        self.iconImageView.image = UIImage(systemName: "folder")
        self.iconImageView.tintColor = UIColor.white
        
        _ = self.nameLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.textColor .~ UIColor.white
            |> \.numberOfLines .~ 1
        
        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemSubDescription(_:)
            |> \.textColor .~ UIColor.white.withAlphaComponent(0.5)
            |> \.text .~ pure("shared by".localized)
            |> \.numberOfLines .~ 1
        
        _ = self.sharedLabel
            |> self.uiContext.decorating.listItemDescription(_:)
            |> \.textColor .~ UIColor.white.withAlphaComponent(0.5)
            |> \.text .~ pure("shared by".localized)
            |> \.numberOfLines .~ 1
        
        self.shareMemberProfileImageView.setupStyling()
        self.shareMemberProfileImageView.layer.cornerRadius = 7.5
        self.shareMemberProfileImageView.clipsToBounds = true
        
        self.shareMemberNameLabel.font = self.uiContext.fonts.get(12, weight: .medium)
        self.shareMemberNameLabel.textColor = UIColor.white
        self.shareMemberNameLabel.numberOfLines = 1
    }
    
    private func setupColorbackgoundViewStyling() {
        
        self.colorBackgroundView.backgroundColor = UIColor.from(hex: "#161B22")
        
        self.colorBackgroundView.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        self.colorBackgroundView.layer.borderWidth = 1
        self.colorBackgroundView.layer.cornerRadius = 8
        self.colorBackgroundView.clipsToBounds = true
    }
}

final class EmptyLatestSharedView: BaseUIView, Presenting {
    
    let descriptionLabel = UILabel()
    
    func setupLayout() {
        self.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 10)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = UIColor(red: 30/255, green: 34/255, blue: 40/255, alpha: 1)
        
        _ = self.descriptionLabel
            |> self.uiContext.decorating.listItemTitle
            |> \.textColor .~ UIColor.white.withAlphaComponent(0.8)
            |> \.textAlignment .~ .center
            |> \.numberOfLines .~ 0
    }
}

private extension SharedListIsEmpty {
    
    var isEmpty: Bool {
        guard case .empty = self else { return false }
        return true
    }
    
    var emptyMessage: String? {
        guard case let .empty(signInNeed) = self else { return nil }
        return signInNeed
            ? "A login is required to use the reading list sharing service.".localized
            : "There are no shared reading lists.".localized
    }
}
