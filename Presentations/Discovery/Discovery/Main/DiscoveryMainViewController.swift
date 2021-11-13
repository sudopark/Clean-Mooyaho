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
import Prelude
import Optics

import CommonPresenting

// MARK: - DiscoveryMainViewController

public final class DiscoveryMainViewController: BaseViewController, DiscoveryMainScene {
    
    private let tableView = UITableView()
    private let switchButton = SwitchToMyCollectionButton()
    
    let viewModel: DiscoveryMainViewModel
    
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
    }
    
}

// MARK: - bind

extension DiscoveryMainViewController {
    
    private func bind() {
        
    }
}

// MARK: - setup presenting

extension DiscoveryMainViewController: Presenting, UITableViewDelegate {
    
    
    public func setupLayout() {
        
        self.view.addSubview(tableView)
        tableView.autoLayout.fill(self.view, edges: .init(top: 0, left: 16, bottom: 0, right: 16), withSafeArea: true)
        
        self.view.addSubview(switchButton)
        switchButton.autoLayout.active(with: self.view) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -1)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        switchButton.setupLayout()
        
    }
    
    public func setupStyling() {
        
        self.view.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.showsVerticalScrollIndicator = false
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        
        self.tableView.registerHeaderFooter(SharedCollectionsHeaderView.self)
        self.tableView.registerCell(LatestSharedCollectionCell.self)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
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
    
    let messageLabel = UILabel()
    let viewAllButton = UIButton(type: .system)
    
    func setupLayout() {
        
        self.contentView.addSubview(viewAllButton)
        viewAllButton.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
        }
        
        self.contentView.addSubview(messageLabel)
        messageLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: viewAllButton.leadingAnchor, constant: -8)
        }
    }
    
    func setupStyling() {
        
        _ = self.messageLabel
            |> self.uiContext.decorating.listSectionTitle(_:)
            |> \.numberOfLines .~ 1
            |> \.textColor .~ UIColor.white.withAlphaComponent(0.8)
            |> \.text .~ pure("Shared read collections".localized)
        
        self.viewAllButton.setTitle("View all".localized, for: .normal)
    }
}

final class LatestSharedCollectionCell: BaseTableViewCell, Presenting {
    
    let iconImageView = UIImageView()
    let nameLabel = UILabel()
    let sharedLabel = UILabel()
    let shareMemberProfileImageView = IntegratedImageView()
    let shareMemberNameLabel = UILabel()
    let likeImageView = UIImageView()
    let likeCountLabel = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
}

extension LatestSharedCollectionCell {
    
    func setupLayout() {
        
        self.contentView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        self.contentView.layer.cornerRadius = 3
        self.contentView.clipsToBounds = true
        
        self.contentView.addSubview(iconImageView)
        iconImageView.autoLayout.active(with: self.contentView) {
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
        }
        
        self.contentView.addSubview(nameLabel)
        nameLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 6)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        }
        nameLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.contentView.addSubview(sharedLabel)
        sharedLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
        }
        sharedLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.contentView.addSubview(shareMemberProfileImageView)
        shareMemberProfileImageView.autoLayout.active(with: self.sharedLabel) {
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 6)
            $0.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 6)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 15)
            $0.heightAnchor.constraint(equalToConstant: 15)
        }
        shareMemberProfileImageView.setupLayout()
        
        self.contentView.addSubview(shareMemberNameLabel)
        shareMemberNameLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: shareMemberProfileImageView.trailingAnchor, constant: 4)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -8)
            $0.centerYAnchor.constraint(equalTo: shareMemberProfileImageView.centerYAnchor)
        }
        
        self.contentView.addSubview(likeImageView)
        likeImageView.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 8)
            $0.topAnchor.constraint(equalTo: shareMemberProfileImageView.bottomAnchor, constant: 6)
            $0.widthAnchor.constraint(equalToConstant: 12)
            $0.heightAnchor.constraint(equalToConstant: 12)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -12)
        }
        
        self.contentView.addSubview(likeCountLabel)
        likeCountLabel.autoLayout.active(with: self.likeImageView) {
            $0.leadingAnchor.constraint(equalTo: $1.trailingAnchor, constant: 8)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -8)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = UIColor.from(hex: "#161B22")
        
        self.iconImageView.image = UIImage(systemName: "folder")
        self.iconImageView.tintColor = UIColor.white
        
        _ = self.nameLabel
            |> self.uiContext.decorating.listItemTitle(_:)
            |> \.textColor .~ UIColor.white
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
        
        self.likeImageView.image = UIImage(systemName: "suit.heart")
        self.likeImageView.tintColor = UIColor.systemPink
        _ = self.likeCountLabel
            |> uiContext.decorating.listItemDescription(_:)
            |> \.textColor .~ UIColor.white
            |> \.text .~ pure("- like(s)".localized)
            |> \.numberOfLines .~ 1
    }
}
