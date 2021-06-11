//
//  SearchNewPlaceViewModel.swift
//  PlaceScenes
//
//  Created sudo.park on 2021/06/11.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - CellViewModels

public protocol SearchingNewPlaceCellViewModelType { }

public struct SeerchingNewPlaceAddNewCellViewModel: SearchingNewPlaceCellViewModelType {
    public let providerName: String
    public init(providerName: String) {
        self.providerName = providerName
    }
}

public struct SearchinNewPlaceCellViewModel: SearchingNewPlaceCellViewModelType {
    
    public let placeID: String
    public let placeName: String
    public let position: Coordinate
    public let address: String
    public let thumbNail: ImageSource?
    public let link: String?
    public var distance: String = ""
    public var isSelected: Bool = false
    
    public init(place: SearchingPlace) {
        self.placeID = place.uid
        self.placeName = place.title
        self.position = place.coordinate
        self.address = place.address
        self.thumbNail = place.thumbnail
        self.link = place.link
    }
    
    func distanceCalculated(from userPosition: Coordinate) -> Self {
        var sender = self
        let distanceMeters = sender.position.distance(from: userPosition)
        sender.distance = "\(distanceMeters)m"
        return sender
    }
}


// MARK: - SearchNewPlaceViewModel

public protocol SearchNewPlaceViewModel: AnyObject {

    // interactor
    
    // presenter
}


// MARK: - SearchNewPlaceViewModelImple

public final class SearchNewPlaceViewModelImple: SearchNewPlaceViewModel {
    
    typealias CVMType = SearchingNewPlaceCellViewModelType
    typealias AddCVM = SeerchingNewPlaceAddNewCellViewModel
    typealias PlaceCVM = SearchinNewPlaceCellViewModel
    
    private let userID: String
    private let searchServiceProvider: SearchServiceProvider
    private let userLocationUsecase: UserLocationUsecase
    private let searchNewPlaceUsecase: SearchNewPlaceUsecase
    private let router: SearchNewPlaceRouting
    
    public init(userID: String,
                searchServiceProvider: SearchServiceProvider,
                userLocationUsecase: UserLocationUsecase,
                searchNewPlaceUsecase: SearchNewPlaceUsecase,
                router: SearchNewPlaceRouting) {
        self.userID = userID
        self.searchServiceProvider = searchServiceProvider
        self.userLocationUsecase = userLocationUsecase
        self.searchNewPlaceUsecase = searchNewPlaceUsecase
        self.router = router
        
        self.internalBinding()
        self.refreshList()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let curentUserLocation = BehaviorRelay<LastLocation?>(value: nil)
        let cellViewModels = BehaviorRelay<[CVMType]>(value: [])
        let selectPlaceID = BehaviorRelay<String?>(value: nil)
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SearchNewPlaceViewModelImple Interactor

extension SearchNewPlaceViewModelImple {
    
    public func refreshList() {
        
        let userID = self.userID
        
        let updateUserLocation: (LastLocation) -> Void = { [weak self] location in
            self?.subjects.curentUserLocation.accept(location)
        }
        
        let refreshDefaultListNearby: (LastLocation) -> Void = { [weak self] location in
            let userLocation = UserLocation(userID: userID, lastLocation: location)
            self?.searchNewPlaceUsecase.startSearchPlace(for: .empty, in: userLocation)
        }
        
        self.userLocationUsecase.fetchUserLocation()
            .do(onNext: updateUserLocation)
            .subscribe(onSuccess: refreshDefaultListNearby)
            .disposed(by: self.disposeBag)
    }
    
    public func loadMore() {
        self.searchNewPlaceUsecase.loadMorePlaceSearchResult()
    }
    
    public func search(_ title: String) {
        guard let location = self.subjects.curentUserLocation.value else { return }
        let userLocation = UserLocation(userID: self.userID, lastLocation: location)
        self.searchNewPlaceUsecase.startSearchPlace(for: .some(title), in: userLocation)
    }
    
    public func toggleSelectPlace(_ placeID: String) {
        
        let cellViewModels = self.subjects.cellViewModels.value.compactMap{ $0 as? PlaceCVM }
        guard let place = cellViewModels.first(where: { $0.placeID == placeID }) else { return }
        
        func select() {
            self.subjects.selectPlaceID.accept(placeID)
            place.link.whenExists {
                self.router.showPlaceDetail(placeID, link: $0)
            }
        }
        
        func deselect() {
            self.subjects.selectPlaceID.accept(nil)
        }
        
        let currentSelectedID = self.subjects.selectPlaceID.value
        let alreadySelected = currentSelectedID != nil && currentSelectedID == placeID
        return alreadySelected ? deselect() : select()
    }
}


// MARK: - SearchNewPlaceViewModelImple Presenter

extension SearchNewPlaceViewModelImple {
    
    private var placeCellViewModels: Observable<[PlaceCVM]> {
        
        
        let applyDistance: ([PlaceCVM]) -> [PlaceCVM] = { [weak self] cellViewModels in
            guard let userLocation = self?.subjects.curentUserLocation.value else { return cellViewModels }
            let coordinate = Coordinate(latt: userLocation.lattitude, long: userLocation.longitude)
            return cellViewModels.map{ $0.distanceCalculated(from: coordinate) }
        }
        let cellViewModels = self.searchNewPlaceUsecase.newPlaceSearchResult.debug("⛳️")
            .map{ $0?.places.map(PlaceCVM.init(place:)) ?? []}
            .map(applyDistance)
        
        let appySelected: ([PlaceCVM], String?) -> [PlaceCVM] = { cellViewModels, selectedID in
            return cellViewModels.map{ $0.selectedFlagUpdated(selectedID) }
        }
        
        return Observable
            .combineLatest(cellViewModels, self.subjects.selectPlaceID,
                           resultSelector: appySelected)
    }
    
    private func internalBinding() {
        
        let serviceProviderName = self.searchServiceProvider.serviceName
        
        let insertAddCell: ([PlaceCVM]) -> [CVMType] = { placeCellViewModels in
            return [AddCVM(providerName: serviceProviderName)] + placeCellViewModels
        }
        
        self.placeCellViewModels
            .map(insertAddCell)
            .subscribe(onNext: { [weak self] cellViewModels in
                self?.subjects.cellViewModels.accept(cellViewModels)
                self?.updateSelectedCellExists(cellViewModels)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func updateSelectedCellExists(_ newCellViewModels: [CVMType]) {
        guard let currentSelectedID = self.subjects.selectPlaceID.value else { return }
        let placeCellViewModels = newCellViewModels.compactMap{ $0 as? PlaceCVM }
        let isNotExisting = placeCellViewModels.first(where: { $0.placeID == currentSelectedID }) == nil
        isNotExisting.then {
            self.subjects.selectPlaceID.accept(nil)
        }
    }
    
    public var cellViewModels: Observable<[SearchingNewPlaceCellViewModelType]> {
        return self.subjects.cellViewModels.asObservable()
    }
    
    public var isPlaceSelectConfirmable: Observable<Bool> {
        return self.subjects.selectPlaceID.map{ $0 != nil }
            .distinctUntilChanged()
    }
}


private extension SearchinNewPlaceCellViewModel {
    
    func selectedFlagUpdated(_ selectedPlaceID: String?) -> Self {
        var sender = self
        sender.isSelected = selectedPlaceID == sender.placeID
        return sender
    }
}
