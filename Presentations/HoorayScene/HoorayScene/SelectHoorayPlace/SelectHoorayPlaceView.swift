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
    let controlButtonsView = UIView()
    let controlLineView = UIView()
    let refreshButton = UIButton(type: .system)
    
    func setupLayout() {
        
        self.addSubview(searchBar)
        searchBar.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor)
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
        
        self.addSubview(controlButtonsView)
        controlButtonsView.autoLayout.active(with: self.mapView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -6)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -12)
        }
        
        controlButtonsView.addSubview(addPlaceButton)
        addPlaceButton.autoLayout.active(with: self.controlButtonsView) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 6)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 6)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -6)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
        
        controlButtonsView.addSubview(controlLineView)
        controlLineView.autoLayout.active(with: self.controlButtonsView) {
            $0.widthAnchor.constraint(equalTo: $1.widthAnchor)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.topAnchor.constraint(equalTo: addPlaceButton.bottomAnchor, constant: 6)
            $0.heightAnchor.constraint(equalToConstant: 0.5)
        }
        
        controlButtonsView.addSubview(refreshButton)
        refreshButton.autoLayout.active(with: self.controlButtonsView) {
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.topAnchor.constraint(equalTo: controlLineView.bottomAnchor, constant: 6)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor, constant: -6)
            $0.widthAnchor.constraint(equalToConstant: 22)
            $0.heightAnchor.constraint(equalToConstant: 22)
        }
    }
    
    func setupStyling() {
        
        self.backgroundColor = self.uiContext.colors.appBackground
        
        self.mapView.isZoomEnabled = true
        self.mapView.isScrollEnabled = true
        self.mapView.showsUserLocation = true
        
        self.searchBar.setupStyling()
        self.searchBar.inputField.placeholder = "Enter a place title"
        
        self.controlButtonsView.backgroundColor = self.uiContext.colors.appBackground.withAlphaComponent(0.8)
        self.controlButtonsView.layer.cornerRadius = 5
        self.controlButtonsView.clipsToBounds = true
        self.controlLineView.backgroundColor = self.uiContext.colors.text.withAlphaComponent(0.1)
        
        self.addPlaceButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        self.addPlaceButton.tintColor = .lightGray
        self.refreshButton.setImage(UIImage(systemName: "location.fill"), for: .normal)
        self.refreshButton.tintColor = .lightGray
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
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 4)
        }
    }
    
    func setupStyling() {
        
        self.label.numberOfLines = 1
        self.label.text = "Select a place".localized
        self.label.font = UIFont.systemFont(ofSize: 13)
        self.label.textColor = self.uiContext.colors.text.withAlphaComponent(0.4)
        self.backgroundColor = self.uiContext.colors.appBackground
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
        self.distanceLabel.text = cellViewModel.distanceText
        self.checkImageView.isHidden = cellViewModel.isSelected == false
    }
}

extension SelectHooraySuggestPlaceCell: Presenting {
    
    func setupLayout() {
        
        self.contentView.addSubview(checkImageView)
        checkImageView.autoLayout.active(with: self.contentView) {
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
        }
        
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: checkImageView.leadingAnchor, constant: -8)
        }
        
        self.contentView.addSubview(distanceLabel)
        distanceLabel.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
            $0.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)
            $0.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        }
    }
    
    func setupStyling() {
        
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        self.distanceLabel.textColor = .darkGray
        self.distanceLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.checkImageView.image = UIImage(systemName: "checkmark.circle.fill")
        self.checkImageView.isHidden = true
    }
}


// MARK: - SelectPlaceEmptyResultView

final class SelectPlaceEmptyResultView: BaseUIView, Presenting {
    
    let descriptionLabel = UILabel()
    let addPlaceButton = UIButton(type: .system)
    
    func setupLayout() {
        
        self.addSubview(descriptionLabel)
        descriptionLabel.autoLayout.active(with: self) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: -10)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        
        self.addSubview(addPlaceButton)
        addPlaceButton.autoLayout.active(with: descriptionLabel) {
            $0.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            $0.topAnchor.constraint(equalTo: $1.bottomAnchor, constant: 8)
        }
    }
    
    func setupStyling() {
        
        self.descriptionLabel.decorate(self.uiContext.deco.placeHolder)
        self.descriptionLabel.text = "No results were found for the place search.".localized
        self.descriptionLabel.textAlignment = .center
        
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        self.addPlaceButton.setAttributedTitle("Add Place".with(attribute: attr), for: .normal)
    }
}


// MARK: - SelectHoorayView

final class SelectHoorayPlaceView: BaseUIView, Presenting {
    
    let headerView = SelectHoorayHeaderView()
    let tableView = UITableView(frame: .zero, style: .grouped)
    let confirmButton = UIButton(type: .system)
    let emptyView = SelectPlaceEmptyResultView()
    
    var mapView: MKMapView {
        return self.headerView.mapView
    }
    
    func setupLayout() {
        
        self.addSubview(confirmButton)
        confirmButton.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor, constant: 20)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor,
                                         constant: -20)
            $0.bottomAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            $0.heightAnchor.constraint(equalToConstant: 40)
        }
        
        self.addSubview(headerView)
        headerView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.heightAnchor.constraint(equalToConstant: 300)
        }
        self.headerView.setupLayout()
        
        self.addSubview(tableView)
        tableView.autoLayout.active(with: self) {
            $0.leadingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.leadingAnchor)
            $0.topAnchor.constraint(equalTo: headerView.bottomAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.safeAreaLayoutGuide.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
        }
        
        self.bringSubviewToFront(self.confirmButton)
    }
    
    func setupStyling() {
        self.headerView.setupStyling()
        
        self.mapView.registerMarkerAnnotationView(for: PlaceAnnotation.self)
        
        self.tableView.registerHeaderFooter(SelectHooraySuggestSectionHeaderView.self)
        self.tableView.registerCell(SelectHooraySuggestPlaceCell.self)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = .init(top: 0, left: 0, bottom: 60, right: 0)
        self.tableView.backgroundColor = self.uiContext.colors.appBackground
        
        self.tableView.backgroundView = self.emptyView
        self.emptyView.setupLayout()
        self.emptyView.setupStyling()
        self.emptyView.isHidden = true
        
        self.confirmButton.layer.cornerRadius = 5
        self.confirmButton.clipsToBounds = true
        self.confirmButton.backgroundColor = UIColor.systemBlue
        self.confirmButton.setTitle("Confirm", for: .normal)
        self.confirmButton.setTitleColor(.white, for: .normal)
    }
}



// MARK: - SelectPlaceAnnotationView

public class PlaceAnnotation: NSObject, MKAnnotation {
    
    @objc public dynamic var coordinate: CLLocationCoordinate2D
    public let title: String?
    public let subtitle: String?
    public let placeID: String
    public let isSelected: Bool
    
    public init(placeID: String,
                latt: Double, long: Double,
                title: String, subtitle: String? = nil,
                isSelected: Bool) {
        
        self.placeID = placeID
        self.coordinate = .init(latitude: latt, longitude: long)
        self.title = title
        self.subtitle = subtitle
        self.isSelected = isSelected
    }
}
