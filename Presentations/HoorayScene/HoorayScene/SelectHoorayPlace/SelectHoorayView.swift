//
//  SelectHoorayView.swift
//  HoorayScene
//
//  Created by sudo.park on 2021/06/09.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa

import CommonPresenting


// MARK: - SelectHoorayHeaderView

final class SelectHoorayHeaderView: BaseUIView, Presenting {
    
    let mapView = MKMapView()
    let addPlaceButton = UIButton(type: .system)
    let searchBar = SearchBar()
    let refreshButton = UIButton(type: .system)
    
    func setupLayout() {
        
        self.addSubview(searchBar)
        searchBar.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        }
        self.searchBar.setupLayout()
        
        self.addSubview(mapView)
        mapView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            $0.topAnchor.constraint(equalTo: self.topAnchor)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: searchBar.topAnchor)
        }
        
        self.addSubview(addPlaceButton)
        addPlaceButton.autoLayout.active(with: self.mapView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 30)
            $0.heightAnchor.constraint(equalToConstant: 30)
        }
        
        self.addSubview(refreshButton)
        refreshButton.autoLayout.active(with: self.mapView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -16)
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
        }
    }
    
    func setupStyling() {
        
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.showsUserLocation = false
        self.mapView.showsUserLocation = true
        
        self.searchBar.setupStyling()
        
        self.refreshButton.setImage(UIImage(named: "arrow.clockwise.circle.fill"), for: .normal)
    }
}

// MARK: - SelectHooraySuggestSectionHeaderView

final class SelectHooraySuggestSectionHeaderView: BaseTableViewSectionHeaderFooterView, Presenting {
    
    let label = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(label)
        label.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
    }
    
    func setupStyling() {
        
        self.label.numberOfLines = 1
        self.label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        self.label.textColor = .gray
        self.label.text = "Search result".localized
    }
}


// MARK: - SelectHooraySuggestPlaceCell

final class SelectHooraySuggestPlaceCell: BaseTableViewCell {

    let titleLabel = UILabel()
    let distanceLabel = UILabel()
    let checkImageView = UIImageView()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }

    func setupCell(_ cellViewModel: SuggestPlaceCellViewModel) {
        self.titleLabel.text = cellViewModel.title
        self.distanceLabel.text = cellViewModel.distance
        self.checkImageView.isHidden = cellViewModel.isSelected == false
    }
}

extension SelectHooraySuggestPlaceCell: Presenting {
    
    func setupLayout() {
        
        self.contentView.addSubview(checkImageView)
        checkImageView.autoLayout.active(with: self.contentView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
        }
        
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: checkImageView.leadingAnchor, constant: -8)
        }
        
        self.contentView.addSubview(distanceLabel)
        distanceLabel.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -6)
            $0.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)
            $0.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        }
    }
    
    func setupStyling() {
        
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        self.distanceLabel.textColor = .darkGray
        self.distanceLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.checkImageView.image = UIImage(named: "checkmark.circle.fill")
        self.checkImageView.isHidden = true
    }
}


// MARK: - SelectHoorayView

final class SelectHoorayView: BaseUIView, Presenting {
    
    let headerView = SelectHoorayHeaderView()
    let tableView = UITableView()
    let toolBar = HoorayActionToolbar()
    
    func setupLayout() {
        
        self.addSubview(toolBar)
        toolBar.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor)
        }
        self.toolBar.showSkip = true
        toolBar.setupLayout()
        
        self.addSubview(tableView)
        tableView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: self.toolBar.topAnchor)
        }
        
        self.addSubview(headerView)
        self.tableView.tableHeaderView = headerView
        headerView.autoLayout.active(with: self.tableView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.heightAnchor.constraint(equalTo: $0.widthAnchor, multiplier: 0.7)
        }
        self.headerView.setupLayout()
    }
    
    func setupStyling() {
        self.headerView.setupStyling()
        
        self.tableView.registerHeaderFooter(SelectHooraySuggestSectionHeaderView.self)
        self.tableView.registerCell(SelectHooraySuggestPlaceCell.self)
        self.tableView.rowHeight = UITableView.automaticDimension
        
        self.toolBar.setupStyling()
    }
}
