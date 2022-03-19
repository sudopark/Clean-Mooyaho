//
//  SettingMainViewController.swift
//  SettingScene
//
//  Created sudo.park on 2021/11/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import SwiftUI

import Domain
import CommonPresenting


// MARK: - SettingMainViewController

public final class SettingMainViewController: UIHostingController<SettingMainView>, SettingMainScene, BaseViewControllable {
    
    let viewModel: SettingMainViewModel
    
    public init(viewModel: SettingMainViewModel) {
        self.viewModel = viewModel
        
        let settingView = SettingMainView(viewModel: viewModel)
        super.init(rootView: settingView)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
}


// MARK: - SettingItemCell

import Prelude
import Optics

final class SettingItemCell: BaseTableViewCell {
    
    let titleLabel = UILabel()
    let accentValueLabel = UILabel()
    private var titleLabelTrailing: NSLayoutConstraint!
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupCell(_ cellViewModel: SettingItemCellViewModel) {
        
        self.titleLabel.text = cellViewModel.title
        self.updateAccessoryView(cellViewModel.accessory)
        self.titleLabel.alpha = cellViewModel.isEnable ? 1.0 : 0.5
    }
    
    private func updateAccessoryView(_ accessory: SettingItemCellViewModel.Accessory) {
        switch accessory {
        case .disclosure:
            self.accessoryType = .disclosureIndicator
            self.accentValueLabel.isHidden = true
            self.titleLabelTrailing.constant = 0
            
        case let .accentValue(value):
            self.accessoryType = .none
            self.titleLabelTrailing.constant = -8
            self.accentValueLabel.text = value
            self.accentValueLabel.isHidden = false
        }
    }
}

extension SettingItemCell: Presenting {
    
    func setupLayout() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.contentView.addSubview(accentValueLabel)
        accentValueLabel.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        self.titleLabelTrailing = titleLabel.trailingAnchor
            .constraint(lessThanOrEqualTo: accentValueLabel.leadingAnchor)
        accentValueLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
    
    func setupStyling() {
        
        _ = self.titleLabel
            |> \.textColor .~ self.uiContext.colors.text
            |> \.textAlignment .~ .center
            |> \.numberOfLines .~ 1
        
        _ = self.accentValueLabel
            |> self.uiContext.decorating.listItemAccentText(_:)
            |> \.font .~ self.uiContext.fonts.get(15, weight: .regular)
            |> \.numberOfLines .~ 1
            |> \.isHidden .~ true
    }
}
