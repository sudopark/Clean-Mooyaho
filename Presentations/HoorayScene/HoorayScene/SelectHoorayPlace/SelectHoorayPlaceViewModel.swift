//
//  SelectHoorayPlaceViewModel.swift
//  HoorayScene
//
//  Created sudo.park on 2021/06/08.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//

import Foundation

import RxSwift
import RxRelay

import Domain
import CommonPresenting


// MARK: - SelectHoorayPlaceViewModel

public struct SuggestPlaceCellViewModel {
    
    public let placeID: String
    public let title: String
    public let position: Coordinate
    public var distance: String = ""
    public var isSelected: Bool = false
    
    public init(snippet: PlaceSnippet) {
        self.placeID = snippet.placeID
        self.title = snippet.title
        self.position = .init(latt: snippet.latt, long: snippet.long)
    }
    
    func distanceCalculated(from userPosition: Coordinate) -> Self {
        var sender = self
        let distanceMeters = sender.position.distance(from: userPosition)
        sender.distance = "\(distanceMeters)m"
        return sender
    }
}

public protocol SelectHoorayPlaceViewModel: AnyObject {

    // interactor
    func suggestPlace(by title: String)
    func refreshUserLocation()
    func toggleUpdateSelected(_ placeID: String)
    func skipPlaceInput()
    func confirmSelectPlace()
    func registerNewPlace()
    
    // presenter
    var currentUserLocation: Observable<LastLocation> { get }
    var cellViewModels: Observable<[SuggestPlaceCellViewModel]> { get }
    var selectedPlaceID: Observable<String> { get }
    var isFinishInputEnabled: Observable<Bool> { get }
    var goNextStepWithForm: Observable<NewHoorayForm> { get }
}


// MARK: - SelectHoorayPlaceViewModelImple

public final class SelectHoorayPlaceViewModelImple: SelectHoorayPlaceViewModel {
    
    private let form: NewHoorayForm
    private let userLocationUsecase: UserLocationUsecase
    private let suggestPlaceUsecase: SuggestPlaceUsecase
    private let router: SelectHoorayPlaceRouting
    
    public init(form: NewHoorayForm,
                userLocationUsecase: UserLocationUsecase,
                suggestPlaceUsecase: SuggestPlaceUsecase,
                router: SelectHoorayPlaceRouting) {
        
        self.form = form
        self.userLocationUsecase = userLocationUsecase
        self.suggestPlaceUsecase = suggestPlaceUsecase
        self.router = router
        
        self.internalBinding()
    }
    
    deinit {
        LeakDetector.instance.expectDeallocate(object: self.router)
    }
    
    fileprivate final class Subjects {
        let currentUserLocation = BehaviorRelay<LastLocation?>(value: nil)
        let selectedPlaceID = BehaviorRelay<String?>(value: nil)
        let cellViewModels = BehaviorRelay<[SuggestPlaceCellViewModel]>(value: [])
        let continueNext = PublishSubject<NewHoorayForm>()
    }
    
    private let subjects = Subjects()
    private let disposeBag = DisposeBag()
}


// MARK: - SelectHoorayPlaceViewModelImple Interactor

extension SelectHoorayPlaceViewModelImple {
    
    public func suggestPlace(by title: String) {
        guard let lastLocation = self.subjects.currentUserLocation.value else { return }
        self.requestSuggestPlace(.some(title), in: lastLocation)
    }
    
    public func refreshUserLocation() {
        self.fetchUserLocationAndUpdateList()
    }
    
    public func toggleUpdateSelected(_ placeID: String) {
        let previousSelectedID = self.subjects.selectedPlaceID.value
        let shouldSelect = previousSelectedID != placeID
        if shouldSelect {
            self.subjects.selectedPlaceID.accept(placeID)
        } else {
            self.subjects.selectedPlaceID.accept(nil)
        }
    }
    
    public func skipPlaceInput() {
        
        let confirmed: () -> Void = { [weak self] in
            logger.todoImplement("should move to place select scene")
        }
        guard let form = AlertBuilder(base: .init())
                .message("[TBD] message")
                .confirmed(confirmed)
                .build() else { return }
        
        self.router.alertForConfirm(form)
    }
    
    public func confirmSelectPlace() {
        
        let selectedPlaceID = self.subjects.selectedPlaceID.value
        self.router.closeScene(animated: true) { [weak self] in
            guard let self = self else { return }
            self.form.placeID = selectedPlaceID
            self.subjects.continueNext.onNext(self.form)
        }
    }
    
    public func registerNewPlace() {

        self.router.presentNewPlaceRegisterScene()
    }
    
    private var memberID: String {
        return self.form.publisherID
    }
    
    private func requestSuggestPlace(_ query: SuggestPlaceQuery, in lastLocation: LastLocation) {
        let userLocation = UserLocation(userID: self.memberID, lastLocation: lastLocation)
        self.suggestPlaceUsecase.startSuggestPlace(for: query, in: userLocation)
    }
    
}


// MARK: - SelectHoorayPlaceViewModelImple Presenter

extension SelectHoorayPlaceViewModelImple {
    
    public var currentUserLocation: Observable<LastLocation> {
        return self.subjects.currentUserLocation.compactMap{ $0 }
    }
    
    public var cellViewModels: Observable<[SuggestPlaceCellViewModel]> {
        return self.subjects.cellViewModels.asObservable()
    }
    
    public var selectedPlaceID: Observable<String> {
        return self.subjects.selectedPlaceID.compactMap{ $0 }
    }
    
    public var isFinishInputEnabled: Observable<Bool> {
        return self.subjects.selectedPlaceID
            .map{ $0 != nil }
            .distinctUntilChanged()
    }
    
    public var goNextStepWithForm: Observable<NewHoorayForm> {
        return self.subjects.continueNext.asObservable()
    }
}


// MARK: - internal bind

extension SelectHoorayPlaceViewModelImple {
    
    private typealias CVM = SuggestPlaceCellViewModel
    
    private var suggestedCellViewModels: Observable<[CVM]> {
        
        let cellViewModels = self.suggestPlaceUsecase.placeSuggestResult
            .map{ $0?.places.asCellViewModels() ?? [] }
        
        let applySelectedInfo: ([CVM], String?) -> [CVM] = { cellViewModels, selectedID in
            return cellViewModels.toggleSelected(selectedID)
        }
        
        let applyDistance: ([CVM], LastLocation?) -> [CVM] = { cellViewModels, location in
            guard let location = location else { return cellViewModels }
            let coordinate = Coordinate(latt: location.lattitude, long: location.longitude)
            return cellViewModels.map{ $0.distanceCalculated(from: coordinate) }
        }

        return Observable
            .combineLatest(cellViewModels, self.subjects.selectedPlaceID,
                           resultSelector: applySelectedInfo)
            .withLatestFrom(self.subjects.currentUserLocation,
                            resultSelector: applyDistance)
    }
    
    private func internalBinding() {
        
        self.suggestedCellViewModels
            .subscribe(onNext: { [weak self] cellViewModels in
                self?.subjects.cellViewModels.accept(cellViewModels)
            })
            .disposed(by: self.disposeBag)
        
        self.fetchUserLocationAndUpdateList()
    }
    
    private func fetchUserLocationAndUpdateList() {
        self.userLocationUsecase.fetchUserLocation()
            .subscribe(onSuccess: { [weak self] location in
                self?.subjects.currentUserLocation.accept(location)
                self?.requestSuggestPlace(.empty, in: location)
            })
            .disposed(by: self.disposeBag)
    }
}


private extension LastLocation {
    
    func asUserLocation(_ memberID: String) -> UserLocation {
        return .init(userID: memberID, lastLocation: self)
    }
}

private extension Array where Element == PlaceSnippet {
    
    func asCellViewModels() -> [SuggestPlaceCellViewModel] {
        return self.map(SuggestPlaceCellViewModel.init(snippet:))
    }
}

private extension Array where Element == SuggestPlaceCellViewModel {
    
    func toggleSelected(_ placeID: String?) -> Array {
        return self.map { cellViewModel in
            var cellViewModel = cellViewModel
            cellViewModel.isSelected = cellViewModel.placeID == placeID
            return cellViewModel
        }
    }
}
