//
//  SearchNewPlaceView.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/07/03.
//

import UIKit

import Domain
import CommonPresenting


// MARK: - SearchNewPlaceSectionHeaderView

final class SearchNewPlaceSectionHeaderView: BaseTableViewSectionHeaderFooterView, Presenting {
    
    let titleLabel = UILabel()
//    let serviceImage = UIImage()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 12)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor, constant: 4)
        }
    }
    
    func setupStyling() {
        self.titleLabel.numberOfLines = 1
        self.titleLabel.text = "Place search result".localized
        self.titleLabel.font = UIFont.systemFont(ofSize: 13)
        self.titleLabel.textColor = self.uiContext.colors.text.withAlphaComponent(0.4)
        self.backgroundColor = self.uiContext.colors.appBackground
    }
}


// MARK: - SearchNewPlaceAddCell

final class SearchNewPlaceAddCell: BaseTableViewCell, Presenting {
    let addImageView = UIImageView()
    let label = UILabel()
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(addImageView)
        addImageView.autoLayout.active(with: self.contentView) {
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        
        self.contentView.addSubview(label)
        label.autoLayout.active(with: self.contentView) {
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
            $0.leadingAnchor.constraint(equalTo: addImageView.trailingAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
    }
    
    func setupStyling() {
        
        self.addImageView.image = UIImage(named: "plus")
        
        self.label.font = UIFont.systemFont(ofSize: 13)
        self.label.textColor = UIColor.systemBlue
        self.label.text = "Manually add a new place"
    }
}


// MARK: - SearchNewPlaceCell

final class SearchNewPlaceCell: BaseTableViewCell, Presenting {

    let checkImageView = UIImageView()
    let titleLabel = UILabel()
    let distanceLabel = UILabel()
    let placeImageView = IntegratedImageView()
    
    private var labelLeading: NSLayoutConstraint!
    private var labelTrailing: NSLayoutConstraint!
    
    override func afterViewInit() {
        super.afterViewInit()
        self.setupLayout()
        self.setupStyling()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.placeImageView.cancelSetupImage()
    }
    
    func setupCell(_ cellViewModel: SearchinNewPlaceCellViewModel) {
        
        self.titleLabel.text = cellViewModel.placeName
        
        self.distanceLabel.text = "\(cellViewModel.distanceText) | \(cellViewModel.address)"
        
        self.updateCheckImageShowing(cellViewModel.isSelected)
        self.updatePlaceImageShowing(cellViewModel.thumbNail)
    }
    
    private func updateCheckImageShowing(_ show: Bool) {
        if show {
            self.labelLeading.constant = 16 + 8 + 20
            self.checkImageView.isHidden = false
        } else {
            self.checkImageView.isHidden = true
            self.labelLeading.constant = 16
        }
    }
    
    private func updatePlaceImageShowing(_ source: ImageSource?) {
        self.placeImageView.cancelSetupImage()
        if let source = source {
            self.labelTrailing.constant = -16 - 8 - 50
            self.placeImageView.isHidden = false
            self.placeImageView.setupImage(using: source, resize: .init(width: 50, height: 50))
        } else {
            self.placeImageView.isHidden = true
            self.labelTrailing.constant = -16
        }
    }
    
    func setupLayout() {
        
        self.contentView.addSubview(checkImageView)
        checkImageView.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 20)
            $0.heightAnchor.constraint(equalToConstant: 20)
            $0.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16)
            $0.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        }
        
        let labelContentView = UIView()
        self.contentView.addSubview(labelContentView)
        labelContentView.autoLayout.active(with: self.contentView) {
            $0.topAnchor.constraint(greaterThanOrEqualTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: $1.bottomAnchor, constant: -8)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        let leadAndtrailings = labelContentView.autoLayout.make(with: self.contentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
        }
        self.labelLeading = leadAndtrailings.first
        self.labelLeading.isActive = true
        self.labelTrailing = leadAndtrailings.last
        self.labelTrailing.isActive = true
        
        labelContentView.addSubview(titleLabel)
        titleLabel.autoLayout.active(with: labelContentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.topAnchor.constraint(equalTo: $1.topAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
        }
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        labelContentView.addSubview(distanceLabel)
        distanceLabel.autoLayout.active(with: labelContentView) {
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: $1.bottomAnchor)
            $0.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6)
        }
        distanceLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        self.contentView.addSubview(placeImageView)
        placeImageView.autoLayout.active(with: self.contentView) {
            $0.widthAnchor.constraint(equalToConstant: 50)
            $0.heightAnchor.constraint(equalToConstant: 50)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.topAnchor.constraint(greaterThanOrEqualTo: $1.topAnchor, constant: 8)
            $0.bottomAnchor.constraint(lessThanOrEqualTo: $1.bottomAnchor, constant: -8)
            $0.centerYAnchor.constraint(equalTo: $1.centerYAnchor)
        }
        placeImageView.setupLayout()
    }
    
    func setupStyling() {
        
        self.titleLabel.textColor = self.uiContext.colors.text
        self.titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        self.titleLabel.numberOfLines = 0
        
        self.distanceLabel.textColor = .darkGray
        self.distanceLabel.font = UIFont.systemFont(ofSize: 12)
        self.distanceLabel.numberOfLines = 2
        
        self.checkImageView.image = UIImage(named: "checkmark.circle.fill")
        self.checkImageView.isHidden = true
        
        
        self.placeImageView.setupStyling()
        self.placeImageView.layer.cornerRadius = 3
        self.placeImageView.clipsToBounds = true
    }
}
