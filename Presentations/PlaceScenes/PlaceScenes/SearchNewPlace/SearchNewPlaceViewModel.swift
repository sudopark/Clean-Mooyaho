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

public struct SeerchingNewPlaceAddNewCellViewModel: SearchingNewPlaceCellViewModelType { }

public struct SearchinNewPlaceCellViewModel: SearchingNewPlaceCellViewModelType {
    
    public let placeID: String
    public let placeName: String
    public let position: Coordinate
    public let address: String
    public let thumbNail: ImageSource?
    public let link: String?
    public let contact: String?
    public var distance: Meters = 0
    public var distanceText: String = ""
    public var isSelected: Bool = false
    
    public var hasLink: Bool {
        return self.link != nil
    }
    
    public init(place: SearchingPlace) {
        self.placeID = place.uid
        self.placeName = place.title
        self.position = place.coordinate
        self.address = place.address
        self.thumbNail = place.thumbnail
        self.link = place.link
        self.contact = place.contact
    }
    
    func distanceCalculated(from userPosition: Coordinate) -> Self {
        var sender = self
        let distanceMeters = sender.position.distance(from: userPosition)
        sender.distance = distanceMeters
        sender.distanceText = distanceMeters.asDistanceText()
        return sender
    }
}

enum SearchinNewPlaceCellAction {
    case showDetail(_ placeID: String)
}

// MARK: - SearchNewPlaceViewModel

public protocol SearchNewPlaceViewModel: AnyObject {

    // interactor
    func refreshList()
    func loadMore()
    func search(_ title: String)
    func showPlaceDetail(_ placeID: String)
    func toggleSelectPlace(_ placeID: String)
    func finishSearch()
    func confirmSelect()
    func requestManualRegisterPlace()
    
    // presenter
    var cellViewModels: Observable<[SearchingNewPlaceCellViewModelType]> { get }
    var currentPlaceMark: String? { get }
    var isPlaceSelectConfirmable: Observable<Bool> { get }
    var isRegistering: Observable<Bool> { get }
    var newRegistered: Observable<Place> { get }
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
    private let registerNewPlaceUsecase: RegisterNewPlaceUsecase
    private let router: SearchNewPlaceRouting
    
    public init(userID: String,
                searchServiceProvider: SearchServiceProvider,
                userLocationUsecase: UserLocationUsecase,
                searchNewPlaceUsecase: SearchNewPlaceUsecase,
                registerNewPlaceUsecase: RegisterNewPlaceUsecase,
                router: SearchNewPlaceRouting) {
        self.userID = userID
        self.searchServiceProvider = searchServiceProvider
        self.userLocationUsecase = userLocationUsecase
        self.searchNewPlaceUsecase = searchNewPlaceUsecase
        self.registerNewPlaceUsecase = registerNewPlaceUsecase
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
        let isRegistering = BehaviorRelay<Bool>(value: false)
        let newPlace = PublishSubject<Place>()
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
        let params: SuggestPlaceQuery = title.isEmpty ? .empty : .some(title)
        self.searchNewPlaceUsecase.startSearchPlace(for: params, in: userLocation)
    }
    
    public func showPlaceDetail(_ placeID: String) {
        let cellViewModels = self.subjects.cellViewModels.value.compactMap{ $0 as? PlaceCVM }
        guard let detailLink = cellViewModels.first(where: { $0.placeID == placeID })?.link else {
            return
        }
        self.router.showPlaceDetail(placeID, link: detailLink)
    }
    
    public func toggleSelectPlace(_ placeID: String) {
        
        let cellViewModels = self.subjects.cellViewModels.value.compactMap{ $0 as? PlaceCVM }
        guard let _ = cellViewModels.first(where: { $0.placeID == placeID }) else { return }
        
        func select() {
            self.subjects.selectPlaceID.accept(placeID)
        }
        
        func deselect() {
            self.subjects.selectPlaceID.accept(nil)
        }
        
        let currentSelectedID = self.subjects.selectPlaceID.value
        let alreadySelected = currentSelectedID != nil && currentSelectedID == placeID
        return alreadySelected ? deselect() : select()
    }
    
    public func finishSearch() {
        self.searchNewPlaceUsecase.finishSearchPlace()
    }
    
    public func confirmSelect() {
        
        let total = self.registerNewPlaceUsecase.placeCategoryTags()
        guard let result = self.router.showSelectPlaceCateTag(startWith: [], total: total) else {
            return
        }
        result.selectedTags.take(1)
            .subscribe(onNext: { [weak self] tags in
                self?.requestRegisterNewPlace(tags)
            })
            .disposed(by: self.disposeBag)
    }
    
    private func requestRegisterNewPlace(_ tags: [Domain.Tag]) {
        
        guard let selectID = self.subjects.selectPlaceID.value,
              let place = self.subjects.cellViewModels.value.selectedCell(selectID),
              let form = place.newPlaceForm(self.userID, tags: tags) else { return }
        
        let handleRegistered: (Place) -> Void = { [weak self] newPlace in
            self?.subjects.isRegistering.accept(false)
            self?.router.closeScene(animated: true) {
                self?.subjects.newPlace.onNext(newPlace)
            }
        }
        let handleError: (Error) -> Void = { [weak self] error in
            self?.subjects.isRegistering.accept(false)
            self?.router.alertError(error)
        }
        
        self.subjects.isRegistering.accept(true)
        
        self.registerNewPlaceUsecase
            .uploadNewPlace(form)
            .subscribe(onSuccess: handleRegistered, onError: handleError)
            .disposed(by: self.disposeBag)
    }
    
    public func requestManualRegisterPlace() {
        
        guard let output = self.router.showManuallyRegisterPlaceScene(myID: self.userID) else { return  }
        
        let finishRegister: (Place) -> Void = { [weak self] newPlace in
            self?.router.closeScene(animated: false) {
                self?.subjects.newPlace.onNext(newPlace)
            }
        }
        
        output.newPlace
            .take(1)
            .subscribe(onNext: finishRegister)
            .disposed(by: self.disposeBag)
    }
}


// MARK: - SearchNewPlaceViewModelImple Presenter

extension SearchNewPlaceViewModelImple {
    
    private var placeCellViewModels: Observable<[PlaceCVM]> {
        
        let applyDistance: ([PlaceCVM]) -> [PlaceCVM] = { [weak self] cellViewModels in
            guard let userLocation = self?.subjects.curentUserLocation.value else { return cellViewModels }
            let coordinate = Coordinate(latt: userLocation.lattitude, long: userLocation.longitude)
            return cellViewModels.map{ $0.distanceCalculated(from: coordinate) }
                .sorted(by: { $0.distance < $1.distance })
        }
        let cellViewModels = self.searchNewPlaceUsecase.newPlaceSearchResult
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
//
        let insertAddCell: ([PlaceCVM]) -> [CVMType] = { placeCellViewModels in
            return [AddCVM()] + placeCellViewModels
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
    
    public var currentPlaceMark: String? {
        return self.subjects.curentUserLocation.value.flatMap { $0.placeMark?.address }
    }
    
    public var isPlaceSelectConfirmable: Observable<Bool> {
        return self.subjects.selectPlaceID.map{ $0 != nil }
            .distinctUntilChanged()
    }
    
    public var isRegistering: Observable<Bool> {
        return self.subjects.isRegistering.distinctUntilChanged()
    }
    
    public var newRegistered: Observable<Place> {
        return self.subjects.newPlace.asObservable()
    }
}


private extension SearchinNewPlaceCellViewModel {
    
    func selectedFlagUpdated(_ selectedPlaceID: String?) -> Self {
        var sender = self
        sender.isSelected = selectedPlaceID == sender.placeID
        return sender
    }
}

private extension SearchinNewPlaceCellViewModel {
    
    func newPlaceForm(_ userID: String, tags: [PlaceCategoryTag]) -> NewPlaceForm? {
        
        let builder = NewPlaceFormBuilder(base: .init(reporterID: userID, infoProvider: .externalSearch))
            .title(self.placeName)
            .thumbnail(self.thumbNail)
            .searchID(self.placeID)
            .detailLink(self.link)
            .coordinate(self.position)
            .address(self.address)
            .contact(self.contact)
            .categoryTags(tags)
        
        return builder.build()
    }
}

private extension Array where Element == SearchingNewPlaceCellViewModelType {
    
    func selectedCell(_ placeID: String) -> SearchinNewPlaceCellViewModel? {
        return self.compactMap{ $0 as? SearchinNewPlaceCellViewModel }
            .first(where: { $0.placeID == placeID })
    }
}
