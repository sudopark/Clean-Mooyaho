//
//  SuggestPlaceView.swift
//  PlaceScenes
//
//  Created by sudo.park on 2021/05/28.
//

import UIKit

import CommonPresenting


final class SuggestPlaceView: BaseUIView {
    
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    let topSeperatorView = UIView()
    let refreshButton = UIButton(type: .system)
    let searchButton = UIButton(type: .system)
    let filterButton = UIButton(type: .system)
    let tableView = UITableView()
}


extension SuggestPlaceView: Presenting {
    
    func setupLayout() {
        
        self.addSubview(blurEffectView)
        blurEffectView.autoLayout.activeFill(self)
        
        self.addSubview(topSeperatorView)
        topSeperatorView.autoLayout.active(with: self) {
            $0.topAnchor.constraint(equalTo: $1.topAnchor, constant: 8)
            $0.centerXAnchor.constraint(equalTo: $1.centerXAnchor)
            $0.heightAnchor.constraint(equalToConstant: 5)
            $0.widthAnchor.constraint(equalToConstant: 40)
        }
        
        self.addSubview(refreshButton)
        refreshButton.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 35)
            $0.heightAnchor.constraint(equalToConstant: 35)
            $0.leadingAnchor.constraint(equalTo: $1.leadingAnchor, constant: 16)
            $0.topAnchor.constraint(equalTo: topSeperatorView.bottomAnchor, constant: 5)
        }
        
        self.addSubview(filterButton)
        filterButton.autoLayout.active(with: self) {
            $0.widthAnchor.constraint(equalToConstant: 35)
            $0.heightAnchor.constraint(equalToConstant: 35)
            $0.trailingAnchor.constraint(equalTo: $1.trailingAnchor, constant: -16)
            $0.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor)
        }
        
        self.addSubview(searchButton)
        searchButton.autoLayout.active {
            $0.widthAnchor.constraint(equalToConstant: 35)
            $0.heightAnchor.constraint(equalToConstant: 35)
            $0.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -12)
            $0.centerYAnchor.constraint(equalTo: refreshButton.centerYAnchor)
        }
        
        self.addSubview(tableView)
        tableView.autoLayout.active {
            $0.leadingAnchor.constraint(equalTo: self.leadingAnchor)
            $0.topAnchor.constraint(equalTo: self.refreshButton.bottomAnchor, constant: 8)
            $0.trailingAnchor.constraint(equalTo: self.trailingAnchor)
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        }
    }
    
    func setupStyling() {
        
        self.topSeperatorView.backgroundColor = .black.withAlphaComponent(0.14)
        self.topSeperatorView.layer.cornerRadius = 2.5
        
        self.refreshButton.backgroundColor = .red
        
        self.searchButton.backgroundColor = .red
        
        self.filterButton.backgroundColor = .red
        
        self.tableView.backgroundColor = .clear
    }
}
