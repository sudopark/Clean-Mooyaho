//
//  SelectHoorayPlaceViewController.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import UIKit
import MapKit

import RxSwift
import RxCocoa
import RxDataSources

import CommonPresenting


// MARK: - SelectHoorayPlaceViewController

public final class SelectHoorayPlaceViewController: BaseViewController, SelectHoorayPlaceScene {
    
    let selectView = SelectHoorayPlaceView()
    let viewModel: SelectHoorayPlaceViewModel
    
    private typealias CellViewModel = SuggestPlaceCellViewModel
    private typealias Section = SectionModel<String, CellViewModel>
    private typealias DataSource = RxTableViewSectionedReloadDataSource<Section>
    
    private var dataSource: DataSource!
    
    public init(viewModel: SelectHoorayPlaceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.viewModel)
        LeakDetector.instance.expectDeallocate(object: self.selectView)
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

extension SelectHoorayPlaceViewController {
    
    private func bind() {
        
        self.viewModel.isFinishInputEnabled
            .map{ $0.invert() }
            .asDriver(onErrorDriveWith: .never())
            .drive(self.selectView.confirmButton.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        self.selectView.headerView.searchBar.rx.text
            .skip(1)
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] text in
                self?.viewModel.suggestPlace(by: text)
            })
            .disposed(by: self.disposeBag)
        
        self.selectView.headerView.refreshButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.refreshUserLocation()
            })
            .disposed(by: self.disposeBag)
        
        self.selectView.headerView.addPlaceButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.registerNewPlace()
            })
            .disposed(by: self.disposeBag)
        
        self.selectView.confirmButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel.confirmSelectPlace()
            })
            .disposed(by: self.disposeBag)
        
        self.rx.viewDidLayoutSubviews.take(1)
            .subscribe(onNext: { [weak self] _ in
                self?.bindMapView()
                self?.bindTableView()
            })
            .disposed(by: self.disposeBag)
        
        let addTriggers = Observable.merge(self.selectView.emptyView.addPlaceButton.rx.tap.asObservable(),
                                           self.selectView.headerView.addPlaceButton.rx.tap.asObservable())
        addTriggers
            .subscribe(onNext: { [weak self] in
                self?.viewModel.registerNewPlace()
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindMapView() {
        
        self.viewModel.cameraFocus
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] focus in
                self?.selectView.headerView.mapView
                    .updateCameraPosition(latt: focus.coordinate.latt,
                                          long: focus.coordinate.long,
                                          zoomDistanceLevel: 500, with: focus.animation)
            })
            .disposed(by: self.disposeBag)

        self.viewModel.cellViewModels
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] cellViewModels in
                self?.updateAnnotations(cellViewModels.map{ $0.asAnnotation()} )
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.selectedPlaceID
            .asDriver(onErrorDriveWith: .never())
            .drive(onNext: { [weak self] placeID in
                self?.updateAnnotationSelection(placeID)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func makeDataSource() -> DataSource {
        
        typealias TableViewDataSource = TableViewSectionedDataSource<Section>
        let configureCell: (TableViewDataSource, UITableView, IndexPath, CellViewModel) -> UITableViewCell
        configureCell = { _, tableview, indexPath, cellViewModel in
            let cell: SelectHooraySuggestPlaceCell = tableview.dequeueCell()
            cell.setupCell(cellViewModel)
            return cell
        }
        return .init(configureCell: configureCell)
    }
    
    private func bindTableView() {
        
        self.dataSource = self.makeDataSource()
        
        let updateEmptyViewVisibility: ([Section]) -> Void = { [weak self] section in
            let isEmpty = section.first?.items.isEmpty ?? true
            self?.selectView.emptyView.isHidden = isEmpty == false
        }
        
        self.viewModel.cellViewModels
            .map{ [Section(model: "suggests", items: $0)] }
            .asDriver(onErrorDriveWith: .never())
            .do(onNext: updateEmptyViewVisibility)
            .drive(self.selectView.tableView.rx.items(dataSource: self.dataSource))
            .disposed(by: self.disposeBag)
        
        self.selectView.tableView.rx.modelSelected(CellViewModel.self)
            .subscribe(onNext: { [weak self] cellViewModel in
                self?.viewModel.toggleUpdateSelected(cellViewModel.placeID)
            })
            .disposed(by: self.disposeBag)
    }
}


// MARK: - handle mkmapview

extension SelectHoorayPlaceViewController: MKMapViewDelegate {
    
    private func updateAnnotations(_ newAnnotations: [PlaceAnnotation]) {
        
        let previousOne = self.selectView.mapView.annotations
        self.selectView.mapView.removeAnnotations(previousOne)
        
        self.selectView.mapView.addAnnotations(newAnnotations)
    }
    
    private func updateAnnotationSelection(_ placeID: String) {
        let annotations = self.selectView.mapView.annotations.compactMap{ $0 as? PlaceAnnotation }
        guard let annotation = annotations.first(where: { $0.placeID == placeID }) else { return }

        self.selectView.mapView.selectAnnotation(annotation, animated: true)
    }
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation.isUserLocation == false else { return nil }
        
        guard let placeAnnotation = annotation as? PlaceAnnotation else { return nil }
        let annotationView = mapView.deqeueMarketAnnotationView(for: placeAnnotation)
        
        annotationView.canShowCallout = true
        
        annotationView.markerTintColor = placeAnnotation.isSelected ? UIColor.systemBlue : UIColor.gray
        
        let checkImageName = placeAnnotation.isSelected ? "checkmark.circle.fill" : "checkmark.circle"
        annotationView.leftCalloutAccessoryView = UIImageView(image: UIImage(named: checkImageName))
        
        let detailButton = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = detailButton
        
        return annotationView
    }
    
    public func mapView(_ mapView: MKMapView,
                        annotationView view: MKAnnotationView,
                        calloutAccessoryControlTapped control: UIControl) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
        
        // TODO: open place detail
    }
    
    public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let placeAnnotation = view.annotation as? PlaceAnnotation else { return }
        self.scrollToPlaceItem(placeAnnotation.placeID)
    }
}

// MARK: - handle tableview

extension SelectHoorayPlaceViewController: UITableViewDelegate {
    
    private func scrollToPlaceItem(_ placeID: String) {
        
        guard let index = self.dataSource[0].items.firstIndex(where: { $0.placeID == placeID }) else { return }
        let indexPath = IndexPath(row: index, section: 0)
        self.selectView.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView: SelectHooraySuggestSectionHeaderView = tableView.dequeueHeaderFooterView()
        return headerView
    }
    
    public func tableView(_ tableView: UITableView,
                          willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = self.uiContext.colors.appBackground
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

// MARK: - setup presenting

extension SelectHoorayPlaceViewController: Presenting {
    
    public func setupLayout() {
        
        self.view.addSubview(selectView)
        selectView.autoLayout.fill(self.view)
        self.selectView.setupLayout()
    }
    
    public func setupStyling() {
        self.selectView.setupStyling()
        self.selectView.tableView.delegate = self
        self.selectView.mapView.delegate = self
    }
}



extension SuggestPlaceCellViewModel {
    
    func asAnnotation() -> PlaceAnnotation {
        
        return PlaceAnnotation(placeID: self.placeID,
                               latt: self.position.latt, long: self.position.long,
                               title: self.title,  subtitle: self.distanceText,
                               isSelected: self.isSelected)
    }
}
